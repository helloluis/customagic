class Cart

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :site
  belongs_to :shop
  belongs_to :user
  has_one :order
  field :guest_id

  index({guest_id:1})

  field :contents, type: Hash, default: {}
  field :discount, type: Float
  field :discount_code
  field :discount_code_type
  field :shipping, type: Float
  field :total,    type: Float

  field :status,   type: String, default: 'shopping'
  field :paid, type: Boolean, default: false
  field :paid_on, type: DateTime
  field :checked_out, type: Boolean, default: false
  # { item_id-variant_slug : { key : '', variant_name: 'small', quantity : 1, price : 1.00, currency : 'USD' } }

  # def total(with_currency = false)
  #   contents.map{|k,p| p['price'].to_f }.sum
  # end

  def add_to_cart(item, variant_name, price, currency, quantity=1)
    
    quantity = 1 if quantity.blank?

    key = make_content_hash_key(item._id, variant_name)

    if self.contents.keys.any? && 
      self.contents.keys.include?(key) &&
      self.contents[key]['variant_name'] == variant_name
      self.contents[key]['quantity'] = self.contents[key]['quantity'].to_i+quantity.to_i
    else
      old_items = self.contents
      new_item = { key => { key: key, 
                            item_id: item._id, 
                            item_name: item.name, 
                            variant_name: variant_name, 
                            quantity: quantity, 
                            price: price, 
                            currency: currency, 
                            discount: item.discount }}
      self.contents = old_items.merge(new_item)
    end
  end

  def contents=(new_contents)
    write_attribute(:contents,new_contents||{})
  end

  def remove_from_cart(item_id, quantity=1)
    if contents.keys.include?(item_id)
      contents[item_id][quantity] -= quantity
      if contents[item_id][:quantity]<=0
        write_attribute(:contents, contents.except(item_id))
      end
    end
  end

  def make_content_hash_key(item_id, variant='')
    item_id.to_s + ( variant.blank? ? '' : "-" + variant.gsub(/[^a-z0-9]/i,'-').gsub(/[\-]+/,'-').gsub(/\-$/,'').downcase[0,32])
  end

  def empty!
    update_attributes(:contents => {})
  end

  def quantities
    contents.values.compact.map{|v|v['quantity'].to_i}.sum
  end

  def paid!(opts={})
    
    @order = Order.where(cart_id: self._id).first

    if !@order
      @order = Order.new(opts.merge(:cart_id => self._id, :shop_id => self.shop_id, :status => 0, :contents => self.contents))
      send_failed_order_notification(self, @order, opts) unless @order.valid? && @order.save
    end
    
    @order.update_status!(1) if @order.valid?

    self.update_attributes(paid: true, paid_on: Time.now)#, contents: {})
    
  end

  def pending_with_paypal!(opts={}, validate=true)
    @order = Order.where(cart_id: self._id).first

    if !@order
      @order = Order.new(opts.merge(:cart_id => self._id, :shop_id => self.shop_id, :status => 0, :contents => self.contents))
      unless @order.save(:validate => validate)
        send_failed_order_notification(self, @order, opts)
      end
    end

    if @order.valid?
      @order.update_status!(6) 
      self.update_attributes(paid: false, order_id: @order._id)
    end
  end

  def denied!(opts={})
    if @order = Order.where(cart_id: self._id).first
      @order.update_status!(4)
    end
    self.update_attributes(paid: false)
  end

  def send_failed_order_notification(cart, order, opts)
    OrderMailer.send_failed_order_notification(cart, order, opts).deliver
  end

  def verify_availability_of_items

    not_available = []
    not_enough_stock = []

    contents.each do |key, hash|
      item_id = hash['item_id']
      if product = shop.products.find(item_id)

        if product.status==3
          
          not_available << [item_id,hash]

        elsif product.price_variants.length==1 && (variant = product.price_variants.first)
          
          if variant['quantity'].to_i==0 
            not_available << [item_id,hash]
          elsif variant['quantity'].to_i<hash['quantity'].to_i
            not_enough_stock << [item_id, hash]
          end

        elsif !hash['variant_name'].trim.blank? && product.price_variants.length>1

          if (variant = product.price_variants.find{|pv| [pv['primary'],pv['secondary']].join(" ").downcase.trim==hash['variant_name'].downcase})

            not_enough_stock << [item_id, hash] if variant['quantity'].to_i<hash['quantity'].to_i

          else
            
            not_available << [item_id, hash]

          end

        end
      else
        
        not_available << [item_id, hash]

      end
    end

    return [not_available, not_enough_stock]

  end

end