# currently only uses Facebook Authentication

class User

  include Mongoid::Document
  include Mongoid::Timestamps

  field :fb_id
  field :fb_url
  field :fb_username
  field :name
  field :first_name
  field :last_name
  field :avatar
  field :email
  field :mobile
  field :city
  field :country
  field :partner, default: "customagic"

  field :access_token
  field :refresh_token
  field :expires_at

  field :favorite_product_ids, type: Array, default: []

  index({fb_id:1, partner: 1})
  index({username:1})
  index({email:1})

  has_one :shop
  has_many :products
  has_many :orders

  validates :fb_id, :uniqueness => true
  validates :name,  :presence => true, :length => { :minimum => 2 }
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }

  after_create :create_shop

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
  
  def create_shop
    Shop.create(name: fb_username||name, user_id: _id)
  end

end