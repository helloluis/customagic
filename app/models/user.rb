# currently only uses Facebook Authentication

class User

  include Mongoid::Document
  include Mongoid::Timestamps
  include User::AuthenticationFields

  #devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [ :facebook ]
  devise :trackable, :validatable, :omniauthable, :omniauth_providers => [ :facebook ]
  
  attr_accessible :urls, :name, :username, :first_name, :last_name, :avatar, :location, :address, :hometown, :city, :country, :state, :extras, :email, :password, :password_confirmation, :remember_me, :provider, :uid, :oauth_token, :oauth_expires_at

  field :urls
  field :name
  field :username
  field :first_name
  field :last_name
  field :avatar
  field :email
  field :mobile
  field :address
  field :location
  field :hometown
  field :city
  field :state
  field :country
  field :postcode
  field :extras
  field :partner, default: "customagic"

  field :access_token
  field :refresh_token
  field :expires_at

  field :favorite_product_ids, type: Array, default: []

  index({uid:1, partner: 1})
  index({username:1})
  index({email:1})

  has_one  :shop
  has_many :products
  has_many :orders
  has_many :carts do
    def active
      where(checked_out: false).desc(:created_at).first
    end
  end

  validates :name,  :presence => true, :length => { :minimum => 2 }
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }

  # after_create :create_shop

  # https://github.com/plataformatec/devise/wiki/OmniAuth%3a-Overview
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(name:auth.extra.raw_info.name,
                           provider:auth.provider,
                           uid:auth.uid,
                           email:auth.info.email,
                           password:Devise.friendly_token[0,20]
                           )
    end
    user
  end

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
    Shop.create(name: username||name, user_id: _id)
  end

  def update_with_facebook(req)
    write_attributes(
      avatar:     req['uid'],
      first_name: req['extra']['raw_info']['first_name'],
      last_name:  req['extra']['raw_info']['last_name'],
      username:   req['extra']['raw_info']['username'],
      urls:       req['urls'],
      location:   req['extra']['raw_info']['location'],
      hometown:   req['extra']['raw_info']['hometown'],
      extras:     req['extra']['raw_info']
    )
  end

  def is_owner?(some_shop)
    self.shop==some_shop
  end

  def find_or_create_cart
    self.carts.active.any? ? self.carts.active.first : self.carts.create
  end

end