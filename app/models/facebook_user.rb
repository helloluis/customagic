class FacebookUser

  include Mongoid::Document
  include Mongoid::Timestamps

  field :fb_id
  field :name
  field :username
  field :avatar
  field :email
  field :mobile
  field :country
  field :url

  field :access_token
  field :refresh_token
  field :expires_at

  field :favorite_product_ids, type: Array, default: []

  index({fb_id:1})
  index({username:1})
  index({email:1})

  has_one :shop
  has_many :items
  has_many :orders

  validates :fb_id, :uniqueness => true
  validates :name,  :presence => true, :length => { :minimum => 2 }
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }

  def toggle_favorite!(product)
    if self.favorite_product_ids.include?(product._id)
      self.favorite_product_ids = favorite_product_ids.reject{|p|p==product._id}
      product.inc(:num_favorites,-1)
      result = 'unfavorited'
    else
      self.favorite_product_ids = favorite_product_ids.push(product._id).uniq
      product.inc(:num_favorites,1)
      result = 'favorited'
    end
    save!
    return { result.to_sym => true}
  end

  def favorite!(product)
    unless self.favorite_product_ids.include?(product._id)
      self.favorite_product_ids << product._id
      self.save
      product.inc(:num_favorites,1)
    end
  end

  def unfavorite!(product)
    if self.favorite_product_ids.include?(product._id)
      self.favorite_product_ids = favorite_product_ids.reject{|p|product._id}
      self.save
      product.inc(:num_favorites,-1)
    end
  end

  def favorite_products(page=1,per=30)
    Kaminari.paginate_array(Product.find(favorite_product_ids)).page(page).per(per)
  end
  
end