class Order

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :cart

  field :session_id
  
  field :first_name,                  default: ""
  field :last_name,                   default: ""
  field :email,                       default: ""
  field :phone                
  field :address,                     default: ""
  field :city,                        default: ""
  field :state                
  field :postcode               
  field :country,                     default: "Location"
  field :instructions         
  field :contents,                    type: Hash
  field :discount,                    type: Float
  field :discount_code          
  field :discount_code_type         
  field :shipping_cost,               type: Float
  field :total_without_shipping,      type: Float
  field :total,                       type: Float
  field :transaction_code

  # these fields are meant to be used for partner-specific transaction-fees
  field :should_be_billed_by_partner, type: Boolean,    default: false
  field :billed_by_partner,           type: Boolean,    default: false
  field :billing_due_on,              type: DateTime
  field :billed_successfully_on,      type: DateTime

  field :shipping_on,                 type: DateTime
  field :processing_on,               type: DateTime
  field :fulfillment_on,              type: DateTime
  field :rejection_on,                type: DateTime
  field :cancellation_on,             type: DateTime
            
  field :messages,                    type: Array,      default: [] # generic messages
  field :processing_message
  field :shipping_message
  field :fulfillment_message
  field :rejection_message
  field :cancellation_message

  field :cancellation_token
  
  field :viewed,                      type: Boolean,    default: false

  field :partner,                     type: String,     default: 'infinitely'

  field :payment_status               #, type: Integer, default: 0 # pending, approved, declined
  field :payment_method,              type: String,     default: 'bank deposit' # bank deposit, gcash, paypal
  field :payment_gateway_raw_message, type: Hash

  field :status,                      type: Integer,    default: 0

  validates_presence_of :first_name, :last_name, :email #, :contents
  
  validate :has_available_stock, :on => :create
  validate :check_email_in_banned_list

  before_save   :attach_to_customer
  before_save   :attach_to_partner
  
  before_create :initialize_billing_field
  before_create :generate_cancellation_token
  before_create :compute_total
  before_create :compute_total_without_shipping

  after_save   :recalculate_shop_total_orders
  
  after_create :send_order_emails
  after_create :increment_discount_code_redemptions

  def name
    [first_name,last_name].join(" ").trim
  end

  def status_in_words
    case status
      when 0 
        "Pending"
      when 1 
        "Processing"
      when 2 
        "Shipped"
      when 3
        "Fulfilled"
      when 4 
        "Cancelled by Customer"
      when 5 
        "Rejected by Seller"
      when 6
        "Pending with Paypal"
      when 7
        "Rejected with Paypal"
    end
  end

  def processing?
    status==1
  end

  def shipped?
    status==2
  end

  def fulfilled?
    status==3
  end
  
  def cancelled?
    status==4
  end

  def rejected?
    status==5
  end

  def is_processable?
    status<2
  end

  def is_shippable?
    status<2 && status!=4 && status!=5
  end

  def is_cancellable?
    status!=2 && status!=3 && status!=4
  end

  def is_fulfillable?
    status==1 || status==2
  end

  def is_rejectable?
    status<2
  end

  def contents
    attributes['contents'].blank? ? {} : attributes['contents'].reject{|k,p| p['quantity'].to_i<1}
  end

  def contents=(new_contents)
    if new_contents.is_a?(String)
      write_attribute(:contents, JSON.parse(new_contents))
    else
      write_attribute(:contents, new_contents)
    end
  end

  def increment_num_orders!
    contents.each do |key,content|
      id = content["_id"] || content["item_id"]
      begin
        product = shop.products.find(id)
        product.num_orders += content['quantity'].to_i
        product.save
      rescue
      end
    end
  end

  def decrement_num_orders!
    contents.each do |key,content|
      id = content["_id"] || content["item_id"]
      begin
        product = shop.products.find(id)
        if (product.num_orders-content['quantity'].to_i) > 0
          product.num_orders -= content['quantity'].to_i
        else
          product.num_orders = 0
        end
        product.save
      rescue
      end
    end
  end

  # we use this to revert quantity-changes brought about by ordering, specifically when the seller rejects the order, or the buyer cancels the order
  def increment_units
    contents.each do |key,content|
      id = content["_id"] || content["item_id"]
      begin
        
        product = shop.products.find(id)
        return false if product.nil? || product.dont_track_quantities?

        new_pv = []

        if product.price_variants.length==1

          new_pv = product.price_variants.first
          new_pv['quantity'] = new_pv['quantity'].to_i+content['quantity'].to_i
          product.num_orders = [product.num_orders-content['quantity'].to_i].max
          product.price_variants = [ new_pv ]

        else

          product.price_variants.each do |pv|
            name = [pv['primary'],pv['secondary']].join(" ").downcase.trim
            name = "" if name==" "
            if name==content['variant_name'].trim.downcase && !pv['quantity'].blank?
              new_pv << pv.merge( 'quantity' => (pv['quantity'].to_i+content['quantity'].to_i) )
            else            
              new_pv << pv
            end
          end
          product.num_orders = [product.num_orders-content['quantity'].to_i].max
          product.price_variants = new_pv

        end
        product.save

      rescue Exception => e
        ::Exceptional::Catcher.handle(e)
        # raise(e)
      end
    end
  end

  def decrement_units 
    contents.each do |key,content|
      id = content["_id"] || content["item_id"]
      begin
        
        product = shop.products.find(id)
        return false if product.dont_track_quantities?

        new_pv = []

        if product.price_variants.length==1

          new_pv = product.price_variants.first
          new_pv['quantity'] = [(new_pv['quantity'].to_i-content['quantity'].to_i),0].max
          product.num_orders += content['quantity'].to_i
          product.price_variants = [ new_pv ]

        else

          product.price_variants.each do |pv|
            name = [pv['primary'],pv['secondary']].join(" ").downcase.trim
            name = "" if name==" "
            #logger.info "!! #{content['variant_name']} MATCHES? #{name} #{name==content['variant_name'].trim.downcase}"
            if name==content['variant_name'].trim.downcase && !pv['quantity'].blank?
              new_pv << pv.merge( 'quantity' => [(pv['quantity'].to_i-content['quantity'].to_i),0].max )
            else            
              new_pv << pv
            end
          end
          product.num_orders += content['quantity'].to_i
          product.price_variants = new_pv

        end
        product.save

      rescue Exception => e
        ::Exceptional::Catcher.handle(e)
        # raise(e)
      end
    end
  end

  def has_available_stock
    contents.each do |id,content|
      id = content["_id"] || content["item_id"]
      if product = self.shop.products.find(id)
        if !product.dont_track_quantities? && product.available_stock < content['quantity'].to_i
          self.errors.add(:base, "There aren't enough available units of the product #{content["name"]} in stock.")
        end
      else
        self.errors.add(:base, "The product #{content["name"]} is not currently available.")
      end
    end
  end

  def send_order_emails
    logger.info "!! ORDER TOTAL: #{self.total_with_shipping_and_with_discount} !!"
    OrderMailer.send_order_email_to_store_owner(shop.owner.email, self, shop.site).deliver
    OrderMailer.send_order_email_to_buyer(email, self, shop.site).deliver
  end

  def send_processing_notice
    OrderMailer.send_processing_notice_to_buyer(self, shop.site).deliver
  end

  def send_shipping_notice
    OrderMailer.send_shipping_notice_to_buyer(self, shop.site).deliver
  end

  def send_fulfillment_notice
    OrderMailer.send_fulfillment_notice_to_buyer(self, shop.site).deliver
  end

  def send_cancellation_notice
    OrderMailer.send_cancellation_notice_to_seller(self, shop.site).deliver
    OrderMailer.send_cancellation_notice_to_buyer(self, shop.site).deliver
  end

  def send_rejection_notice
    OrderMailer.send_rejection_notice_to_buyer(self, shop.site).deliver
  end

  def send_message(new_message)
    update_attributes(:messages => self.messages.push(new_message))
    OrderMailer.send_message_to_buyer(self, shop.site, new_message).deliver
  end

  def increment_sales
    return false unless shop && shop.site
    shop.site.total_sales += self.total
    shop.site.save
  end

  def decrement_sales
    shop.site.total_sales -= self.total
    shop.site.save
  end

  def generate_cancellation_token
    self.cancellation_token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def contents_values
    contents.values
  end

  def update_status!(new_status, message=false)
    
    old_status = self.status
    new_status = new_status.to_i

    key = case new_status
      when 0
        "pending"
      when 1
        "processing"
      when 2
        "shipping"
      when 3
        "fulfillment"
      when 4
        "cancellation"
      when 5
        "rejection"
    end
    
    write_attribute(:status, new_status)
    write_attributes("#{key}_message".to_sym => message, "#{key}_on".to_sym => Time.now) if key
    save
    
    decrement_units if (new_status==1 && old_status!=6) || new_status==6 
    # don't want to accidentally decrement twice for the same order, so if the method was 6 (paypal), and the approval came in (changing the status to 1),
    # we shouldn't bother decrementing again

    increment_units if new_status==4 || new_status==5 || new_status==7

    unless message.blank?
      case new_status
        when 1
          send_processing_notice
        when 2
          send_shipping_notice
        when 3
          send_fulfillment_notice
        when 5
          send_rejection_notice
        when 6
          send_processing_notice
      end
    end

    send_cancellation_notice if new_status==4
  end

  def contents_with_product_names
    new_contents = {}
    contents.each do |key,content|
      item_id = content["_id"] || content["item_id"]
      begin
        product = shop.products.find(item_id)
        new_contents[key] = content.merge({ 'name' => product.name })
      rescue
        logger.info "!! MISSING PRODUCT #{item_id} IN ORDER #{self._id}"
        new_contents[key] = content
      end
    end
    new_contents
  end

  def contents_with_product_names_values
    contents_with_product_names.values
  end
  
  def compute_total(and_write=true, and_save=false, skip_shipping=false)
    
    new_total = 0.0
    
    contents.each do |k,content|
      new_total += (content['quantity'].to_i * content['price'].to_s.gsub(',','').to_f)
    end

    new_total += (shipping_cost||0.0) unless skip_shipping
    
    return new_total if !and_write && !and_save

    write_attribute(:total, new_total) if and_write
    
    save if and_save

  end

  def attach_to_customer
    if self.shop && self.shop.site && self.email && customer = self.shop.site.customers.find_or_create_by(email: self.email.trim)
      write_attribute(:customer_id, customer._id)
      #logger.info "!! CUSTOMER: #{customer.inspect} !!"
      customer.write_attribute(:name, self.name) if customer.name.blank?
      customer.write_attribute(:first_name, self.first_name)
      customer.write_attribute(:last_name, self.last_name)
      customer.write_attribute(:mobile, self.phone) if customer.mobile.blank?
      customer.write_attribute(:address, self.address) if customer.address.blank?
      customer.write_attribute(:city, self.city) if customer.city.blank?
      customer.write_attribute(:postcode, self.postcode) if customer.postcode.blank?
      customer.write_attribute(:country, self.country) if customer.country.blank?
      customer.write_attribute(:state, self.state) if customer.state.blank?
      customer.write_attribute(:location, self.city + ", " + self.country) if customer.location.blank?
      customer.save # if customer.changed?
    end
  end

  def attach_to_customer!
    attach_to_customer
    save
  end

  def attach_to_partner
    if self.shop && self.shop.site
      write_attribute(:partner, self.shop.site.partner)
    end
  end

  def full_address
    # "#{address}, #{city}, #{state}, #{country} #{postcode}" #.to_utf8 #encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '?')
    "#{address}, #{city}, #{state}, #{country} #{postcode}".encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '?')
  end

  def city_and_country
    # "#{city}, #{country}" #.to_utf8 #.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '?')
    "#{city}, #{country}".encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '?')
  end

  def created
    created_at.in_time_zone(shop.site.time_zone).strftime("%d %b %Y, %H:%M")
  end

  def is_discounted
    (discount||0).to_f>0
  end

  def total_with_discount
    [0,total.to_f-(discount||0).to_f].max.to_f
  end

  def total_without_shipping_and_with_discount
    if discount_code_type=='free_shipping'
      total_without_shipping.to_f
    else
      [0,total_without_shipping.to_f-(discount||0).to_f].max.to_f
    end
  end

  def total_with_shipping_and_with_discount
    if discount && discount_code_type=='free_shipping'
      total_without_shipping.to_f
    else
      [0,(total_without_shipping.to_f - (discount||0))].max.to_f + (shipping_cost||0).to_f
    end
    #total_without_shipping_and_with_discount + (shipping_cost||0)
  end

  def increment_discount_code_redemptions
    if !self.discount_code.blank? && code = self.shop.discount_codes.find_by_code(self.shop, discount_code)
      code.inc(:num_redemptions,1)
    end
  end

  def offline_payment
    payment_method!='paypal' && !(status==6 || status==7)
  end

  def online_payment
    payment_method=='paypal'
  end

  def transaction_fee
    if self.shop.site.plan.transaction_fee && self.shop.site.plan.transaction_fee>0
      self.total*(self.shop.site.plan.transaction_fee.to_f/100)
    else
      0.0
    end
  end

  def compute_total_without_shipping
    if discount && discount_code_type=='free_shipping'
      write_attribute(:total_without_shipping, compute_total(false,false,true))
    else
      write_attribute(:total_without_shipping, total.to_f-(shipping_cost||0).to_f)
    end
  end

  def initialize_billing_field
    is_billable = self.shop.site.is_billable?
    write_attribute(:should_be_billed_by_partner, is_billable)
    if self.should_be_billed_by_partner_changed?
      self.shop.update_attributes(:start_billing_on => is_billable ? Time.now : nil)
    end
    if self.should_be_billed_by_partner? && self.shop.site.next_invoice
      write_attribute(:billing_due_on, self.shop.site.next_invoice)
    end
    true # don't remove this
  end

  def check_email_in_banned_list
    errors.add(:email, "That email is blacklisted.") if self.email && App.banned_emails.include?(self.email.trim.downcase)
  end

  def recalculate_shop_total_orders
    shop.calculate_total_orders_alltime! if shop
  end
end