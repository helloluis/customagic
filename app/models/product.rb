class Product
  
  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps
  include Mongoid::MultiParameterAttributes
  include Product::Characteristics

  belongs_to :shop
  belongs_to :album

  has_one :final_art
  has_many :assets

  has_many :tags, :class_name => "ProductTag"
  has_many :reviews, :class_name => "ProductReview" do
    def featured
      where(:featured => true)
    end

    def all
      desc(:featured).desc(:created_at)
    end

    def for_public
      where(:visible => true).desc(:featured).desc(:created_at)
    end
  end
  has_many :orders

  field :name
  slug  :name,  :scope => :shop, :reserve => [ 'tag', 'tags', 'shop', 'product' ]

  field :description
  field :on_sale,               type: Boolean,  default: false
  field :featured,              type: Boolean,  default: false
  field :sku        
  field :category_slug,         type: String,   default: ''
  field :num_orders,            type: Integer,  default: 0
  field :num_favorites,         type: Integer,  default: 0
  field :status,                type: Integer,  default: 0    # 0 = in progress, 1 = hidden, 2 = visible, 3 = out of stock, 4 = coming soon, 9 = demo
  
  field :campaign_length,       type: Integer,  default: 10  # days

  field :buy_now_price,         type: Float,    default: 350.0
  field :charity_donation,      type: Float,    default: 10.0
  field :base_price,            type: Float,    default: 0.0
  field :group_price,           type: Float,    default: 0.0
  field :lowest_price,          type: Float,    default: 0.0
  field :sales_goal,            type: Integer,  default: 20
  
  field :charity_url

  field :price_variant_classes, type: Hash,     default: { primary: "", secondary: "" }
  field :price_variants,        type: Array,    default: [ { :primary => '',  :secondary => '', :quantity => 10, :price => 100.00 } ]
  # [ 
  #   { :primary => 'small',  :secondary => 'white', :quantity => 10, :price => 100.00 },
  #   { :primary => 'small',  :secondary => 'black', :quantity => 10, :price => 100.00 },
  #   { :primary => 'medium', :secondary => 'white', :quantity => 10, :price => 100.00 },
  #   { :primary => 'medium', :secondary => 'black', :quantity => 10, :price => 100.00 }
  # ]

  field :raw_html

  field :dont_track_quantities,   type: Boolean,  default: true
  field :hide_prices,             type: Boolean,  default: false
  field :images,                  type: Array,    default: []
  field :embedded_video 
  field :tags_array,              type: Array,    default: []
  field :shipping_costs,          type: Array,    default: [[ 'everywhere', 10.00, 5.00 ]]
  field :available_stock,         type: Integer,  default: 10
  field :visible_in_marketplace,  type: Boolean,  default: false
  field :featured_in_marketplace, type: Boolean,  default: false
  field :featured_at,             type: DateTime
  field :num_views,               type: Integer,  default: 0
  field :social_network_links,    type: Array,    default: []
  field :discount,                type: Float,    default: 0
  field :partner,                 type: String,   default: 'happy'
  field :trusted,                 type: Boolean,  default: false
  field :premium,                 type: Boolean,  default: false
  field :deactivated,             type: Boolean,  default: false
  field :has_availability_period, type: Boolean,  default: true
  field :availability_start,      type: DateTime
  # field :availability_end,        type: DateTime
  field :remote_attachment_url

  # search_in :name, :tags_array, {:match => :any}

  RATING_RANGE = (1..5)

  validates_presence_of :name, :minlength => 2, :maxlength => 150
  
  # validate :check_number_of_products

  before_save    :set_partner
  before_save    :check_remote_attachment_url
  after_create   :create_first_asset
  after_create   :update_shop_timestamp

  after_save     :manage_tags
  after_save     :sweep_marketplace_caches
  
  before_destroy :check_album_integrity
  after_destroy  :force_sweep_marketplace_caches

  index({ slug: 1 })

  # index for mongoid::search
  # index({ partner: 1, status: 1, visible_in_marketplace: 1, _keywords: 1 }, { name: 'search_by_relevance' })
  # index({ partner: 1, status: 1, visible_in_marketplace: 1, _keywords: 1, num_orders: -1 }, { name: 'search_by_popularity' })
  # index({ shop_id: 1, status: 1, _keywords: 1 }, { name: 'shop_search'})

  # index for marketplace
  index({ partner: 1, deactivated: 1, category_slug: 1}, { name: 'partner_marketplace_category' })
  index({ partner: 1, status: 1, visible_in_marketplace: 1, featured_in_marketplace: 1, featured_at: -1 }, { name: 'partner_marketplace_visible_and_featured' })
  index({ partner: 1, deactivated: 1, num_views: -1 }, { name: 'partner_sorted_by_most_viewed' })
  index({ partner: 1, deactivated: 1, shop_id: 1, created_at: -1 }, { name: 'partner_shop_newest' })
  index({ partner: 1, deactivated: 1, slugs: 1, created_at: -1 }, { name: 'partner_slug_newest' })
  index({ partner: 1, deactivated: 1, status: 1, visible_in_marketplace: -1, category_slug: 1, trusted: -1, created_at: -1 }, { name: 'trusted_in_marketplace_category' })
  index({ partner: 1, deactivated: 1, status: 1, visible_in_marketplace: -1, category_slug: 1, lowest_price: -1 }, { name: 'cheapest_in_marketplace_category' })
  index({ partner: 1, deactivated: 1, status: 1, visible_in_marketplace: -1, category_slug: 1, created_at: -1 }, { name: 'newest_in_marketplace_category' })
  index({ partner: 1, deactivated: 1, status: 1, visible_in_marketplace: -1, category_slug: 1, num_orders: -1 }, { name: 'most_popular_in_marketplace_category' })

  # index for availability
  index({ has_availability_period: 1, availability_start: 1, status: 1 })

  #index for admin
  index({ partner: 1, featured_in_marketplace: -1, created_at: -1 }, { name: 'admin_partner_featured_newest'})
  index({ partner: 1, status: 1, created_at: -1 }, { name: 'admin_partner_status_newest' })

  index({ shop_id: 1, :_id => 1 })

  def tags
    tags_array.join(", ") unless tags_array.blank?
  end

  def tags=(new_tags)
    self.tags_array = new_tags.blank? ? [] : new_tags.split(",").map(&:strip).reject(&:blank?).map(&:downcase)
  end

  def manage_tags
    if self.tags_array_changed?
      self.tags_array.each do |tag|
        tag_record = self.shop.tags.find_or_create_by(:name => tag) rescue nil
      end
      self.shop.update_tag_counters rescue nil
    end
  end

  def is_orderable?
    status==2
  end
  
  def is_group_orderable?
    status==2 && Time.now<availability_end
  end

  def within_availability_period?
    availability_start >= Time.now.utc && availability_end < Time.now.utc
  end

  def price_variants=(new_price_variants)
    if new_price_variants.is_a? Hash 
      new_price_variants = new_price_variants.values.map(&:values)
    end
    
    write_attribute(:price_variants, new_price_variants)
    write_attribute(:available_stock, new_price_variants.map{|pv| pv['quantity'].to_i }.sum)
    write_attribute(:lowest_price, new_price_variants.map{|pv| pv['price'].to_s.gsub(',','').to_i }.min) #rescue 0.0
  end

  def price_variants_with_discounts
    new_pv = []
    price_variants.each do |pv|
      new_pv << pv.merge({ 'price' => pv['price'].to_s.gsub(',','').to_f*discount_modifier })
    end
    new_pv
  end

  def discount_modifier
    ((discount||0) > 0 ? (100-(discount||0))/100 : 1).to_f
  end

  def is_discounted?
    (discount||0)>0
  end

  def price
    currency = shop.currency_symbol
    price_variants.any? ? currency + price_variants.first['price'].to_s : "FREE"
  end

  def raw_price
    price_variants.any? ? price_variants.first['price'].to_s : "FREE"
  end

  def shipping=(new_shipping_costs)
    if new_shipping_costs.is_a?(Hash)
      new_shipping_costs = new_shipping_costs.values.map(&:values)
    elsif new_shipping_costs.is_a?(Array)
      if new_shipping_costs.first.is_a?(Hash)
        new_shipping_costs = new_shipping_costs.map(&:values)
      else
        new_shipping_costs = new_shipping_costs
      end
    end

    # if the final field (i.e., the price for group shipping is blank, we just copy the price for individual shipping)
    new_shipping_costs.each do |sc|
      if !sc[2] || sc[2].blank?
        sc.pop
        sc.push(sc[1])
      end
    end

    # remove all non-float characters
    new_shipping_costs.each_with_index do |sc,i|
      new_shipping_costs[i][1] = sc[1].gsub(/[^\d\.]/,'').to_f
      new_shipping_costs[i][2] = sc[2].gsub(/[^\d\.]/,'').to_f
    end

    self.shipping_costs = new_shipping_costs
    
  end

  def images=(new_images_stringified)
    if new_images_stringified.is_a?(String) && !new_images_stringified.blank?
      write_attribute(:images, JSON.parse(new_images_stringified))
    elsif new_images_stringified.is_a?(Array)
      write_attribute(:images, new_images_stringified)
    else
      write_attribute(:images, [])
    end
  end

  def status=(new_status)
    write_attribute(:status, new_status)
    write_attribute(:visible_in_marketplace, false) if new_status==1
  end

  def load_previous_shipping_costs
    if previous_product = shop.products.desc(:created_at).first
      self.shipping_costs = previous_product.shipping_costs
    end
  end

  def attributes_for_cart
    attributes.except('images','embedded_video','tags_array','description','created_at', 'updated_at').merge('slug' => slug)
  end

  def sold_out?
    status==3 || available_stock == 0
  end

  def available_stock=(new_available_stock)
    write_attribute(:available_stock, new_available_stock)
    write_attribute(:status, 3) if new_available_stock==0
    write_attribute(:status, 2) if new_available_stock>0
  end

  def price_variants_have_same_price?
    return true if price_variants.nil?
    return true if price_variants.length==1
    return true if price_variants.first.is_a?(Array) && price_variants.map{|pv|pv[1].to_f}.uniq.length==1
    return true if price_variants.first.is_a?(Hash) && price_variants.map{|pv|pv['price'].to_s.gsub(',','').to_f}.uniq.length==1
    return false
  end

  def price_variants_are_nested?
    return true if price_variants.any? && 
      price_variants.first.is_a?(Hash) && 
      !price_variants.first['primary'].blank? && 
      !price_variants.first['secondary'].blank?
  end

  def check_number_of_products
    if self.shop && self.shop.products.length > self.shop.max_products
      errors.add(:base, "You may only have #{self.shop.max_products} listed products. Please remove some before creating more, or upgrade your subscription.")
    end
  end

  def status_in_words
    ['','hidden','visible','out of stock','coming soon','','','','','sample'][status] rescue ''
  end

  def status_in_a_phrase
    stat = (0..4).to_a.include?(status) ? status : 0
    [ (['','Hidden','Visible','Out of stock','Coming soon'][stat] + " Product"), hide_prices? ? "Hidden Prices" : nil ].compact.join(", ")
  end

  def num_variants
    price_variants.length
  end

  def price_variants_as_objects
    arr = []
    price_variants.each do |pv|
      arr<< { :name => [pv['primary'], pv['secondary']].join(" "), 
              :price => is_discounted? ? pv['price'].to_f*((100-discount)/100) : pv['price'], 
              :quantity => pv['quantity'] 
            }
    end
    arr
  end

  def primary_image
    images.first.last rescue ""
  end

  def set_quantity!(idx, quant)
    
    idx = idx.to_i
    pv = self.price_variants

    pv[idx]['quantity'] = quant

    write_attribute(:price_variants, pv)
    write_attribute(:available_stock, self.price_variants.map{|pv|pv['quantity'].to_i}.sum)
    save
    reload
    pv[idx]['quantity']

  end

  def increase_quantity!(idx, increase_by=1)
    
    idx = idx.to_i
    increase_by = increase_by.to_i
    pv = self.price_variants

    orig = pv[idx]['quantity']
    pv[idx]['quantity'] = orig.to_i + increase_by

    write_attribute(:price_variants, pv)
    write_attribute(:available_stock, self.price_variants.map{|pv|pv['quantity'].to_i}.sum)
    save
    reload
    pv[idx]['quantity']
  end

  def decrease_quantity!(idx, decrease_by=1)
    
    idx = idx.to_i
    decrease_by = decrease_by.to_i
    pv = self.price_variants

    orig = pv[idx]['quantity']
    pv[idx]['quantity'] = orig.to_i - decrease_by
    
    write_attribute(:price_variants, pv)
    write_attribute(:available_stock, self.price_variants.map{|pv|pv['quantity'].to_i}.sum)
    save
    reload
    pv[idx]['quantity']

  end

  def primary_variants
    price_variants.map{|pv| pv['primary']}.uniq
  end

  def secondary_variants
    price_variants.map{|pv| pv['secondary']}.uniq
  end

  def absolute_url
    if shop && shop.site
      shop.site.public_url + "/shop/" + slug
    end
  end

  def quantity_display
    dont_track_quantities? ? "-" : available_stock
  end

  def compute_lowest_price(and_save=false)
    begin
      if price_variants.is_a?(Array) && price_variants.first.is_a?(Hash) && price_variants.first['price']
        write_attribute(:lowest_price, price_variants.map{|pv| pv['price'].to_s.gsub(',','').to_i }.min) #rescue 0.0
        save(:validate => false) if and_save 
      end
    rescue
      puts _id
    end
  end

  def lowest_price=(new_lowest_price)
    lowest_price.to_s.gsub(',','').to_i
  end

  def lowest_price_with_discount
    lowest = 0
    lowest = price_variants.map{|pv|pv['price'].to_s.gsub(',','')}.map(&:to_f).min if price_variants.any?
    if is_discounted?
      lowest-(lowest*((discount||0)/100))
    else
      lowest
    end
  end

  def has_available_variant?(name, cart=false, desired_quantity=0)

    return true if dont_track_quantities? || name.blank?
    
    if price_variants.length==1
      matched_variant = price_variants.first 
    else
      matched_variant = price_variants.detect do |variant| 
        name.trim == [variant['primary'], variant['secondary']].reject{|a|a.blank?}.join(" ").trim
      end
    end

    if matched_variant && matched_variant['quantity'].to_i>0
      if cart && cart.contents.any?
        if product_in_cart = cart.contents.detect{|k,v| v['item_id'].to_s==_id.to_s && name.trim == v['variant_name']}
          return (product_in_cart.last['quantity'].to_i+desired_quantity) <= matched_variant['quantity'].to_i
        else
          return true
        end
      else
        return true
      end
    end
    return false
  end

  def view!
    inc(:num_views,1)
  end

  def available_stock_for_variant(name)
    return "infinite" if dont_track_quantities?
    if price_variants.length==1
      matched_variant = price_variants.first 
    else
      matched_variant = price_variants.detect do |variant| 
        name.trim == [variant['primary'], variant['secondary']].reject{|a|a.blank?}.join(" ").trim
      end
    end
    matched_variant['quantity']
  end

  def sweep_marketplace_caches(force_sweep=false)
    if force_sweep ||
      (self.new_record? && self.visible_in_marketplace?) || 
      self.visible_in_marketplace_changed? ||
      self.featured_in_marketplace_changed? ||
      (self.visible_in_marketplace && (self.name_changed? || self.description_changed? || self.price_variants_changed?))
      
      # Rails.cache.delete "views/#{markets_cache_name(true)}"
      # Rails.cache.delete "views/#{markets_cache_name}"
      # Cashier.expire category_slug
      # Cashier.expire shop.site.subdomain
    end
  end

  def force_sweep_marketplace_caches
    sweep_marketplace_caches(true)
  end

  def update_shop_timestamp
    if self.visible_in_marketplace && self.status!=1
      s = self.shop
      s.last_product_created_at = Time.now
      s.save(:validate => false)
    end
  end

  def self.most_recent_from_shops(shops, limit=24)
    result_count = 0
    results = []
    shops.each do |shop|
      if result_count<=limit
        if product = Product.where(:status=>2,:shop_id=>shop._id,:visible_in_marketplace=>true).desc(:created_at).first
          results << product
          result_count+=1
        end
      end
    end
    #logger.info "!! #{results.count}"
    results
  end

  def set_partner
    write_attribute(:partner, self.shop.partner) if self.shop 
  end

  def delete_variant!(idx, and_save=false)
    return false if idx > price_variants.length-1
    # pv = price_variants
    # pv.delete_at(idx)
    self.price_variants.delete_at(idx)
    self.write_attribute(:available_stock, self.price_variants.map{|pv| pv['quantity'].to_i }.sum)
    self.write_attribute(:lowest_price, self.price_variants.map{|pv| pv['price'].to_s.gsub(',','').to_i }.min)
    save if and_save
  end

  def check_album_integrity
    shop.albums.each do |album|
      if album.find{|a| a.products.find{|p| p.first==self._id } }
        album.check_integrity!
      end
    end if shop && shop.albums
  end

  def check_remote_attachment_url
    if remote_attachment_url_changed? && !remote_attachment_url.blank?
      if a = self.shop.site.assets.create(  :meta => { :media_type => "photo" }, 
                                            :data => { :title => "photo" }, 
                                            :remote_attachment_url => remote_attachment_url )

        write_attribute(:images, [ [ a.attachment.url, a.attachment.entry_image.url, a.attachment.medium.url ] ])

      end
    end
  end

  def setup_jobs_for_availability!
    
    if has_availability_period? &&
       availability_start.utc < availability_end.utc && 
       availability_end.utc > Time.now.utc

      Products::SetAvailability.perform_at(availability_start.utc, _id) 
      Products::SetAvailability.perform_at(availability_end.utc, _id) 

    end
  end

  def check_availability_period!
    if has_availability_period?
      update_attribute(:status, 2) if Time.now.utc>=availability_start.utc && Time.now.utc<availability_end.utc
      update_attribute(:status, 1) if availability_start.utc>=Time.now.utc || availability_end.utc<Time.now.utc
    end
  end

  def start_time_must_be_before_end_time
    # if has_availability_period?
    #   errors.add(:base, "Your availability start date must occur before your end date.")
    # end
  end

  def availability_start
    attributes['availability_start'].in_time_zone(self.shop.time_zone) if has_availability_period? && self.shop && !self.attributes['availability_start'].blank?
  end

  def availability_end
    attributes['availability_start'].in_time_zone(self.shop.time_zone) + campaign_length.days if self.shop && !self.attributes['availability_start'].blank?
  end

  def create_first_asset
    self.assets.create(content: "Awesome Shirt", shop: self.shop)
  end

  def create_final_art!
    self.final_art.create(dpi_target: product_type.dpi_target)
  end

  def charity
    unless charity_url.blank?
      App.charities.find{|c| c.url==charity_url}
    end
  end

end