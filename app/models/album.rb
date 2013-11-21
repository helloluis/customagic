class Album

  include Mongoid::Document
  include Mongoid::Slug
  include Mongoid::Timestamps
  include Mongoid::Search
  #include Mongoid::FullTextSearch

  belongs_to :shop, index: true

  #has_many :products

  field :name
  field :description
  field :visible, type: Boolean, default: true
  field :images, type: Array, default: []
  field :counter, type: Integer, default: 0
  field :products, type: Array, default: []

  slug :name, :scope => :shop

  validates_presence_of :name

  validate :check_number_of_albums

  index({slug: 1})
  index({created_at: 1})

  def product_entries(is_owner = true, page=1, per=20)
    
    return [] if products.blank? || products.empty?

    page = page.to_i
    start_idx = ((page||1)-1)*per
    end_idx   = start_idx+(per-1)
    all_products = []
    
    if products_in_range = products[start_idx..end_idx]
      products_in_range.uniq.map do |p| 
        if is_owner==true
          if product = shop.products.find(p.first)
            all_products << product
          end
        else
          if product = shop.products.where(:_id => p.first, :status.ne => 1).first #rescue nil  
            all_products << product
          end
        end
      end
    else
      return []
    end
    
    return all_products.compact
  end

  def products=(new_products)
    if new_products.is_a?(String)
      new_products = JSON.parse(new_products)
    end
    write_attribute(:products,new_products)
  end

  def check_integrity!
    for_removal = []
    products.each_with_index do |p,k|
      unless shop.products.where(:_id => p.first).exists?
        for_removal << k
      end
    end
    # remove from product_entries, then save
    if for_removal.any?
      new_products=[]
      products.each_with_index do |p,k|
        new_products << p unless for_removal.include?(k)
      end
      self.write_attribute(:products, new_products)
      self.save
    end
  end

  def check_number_of_albums
    if self.shop && self.shop.albums.length > self.shop.site.plan.albums
      errors.add(:base, "You may only have #{self.shop.site.plan.albums} albums. Please upgrade your subscription.")
    end
  end

end