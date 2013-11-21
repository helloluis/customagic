class Shop

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  belongs_to :user
  has_many :albums
  has_many :products
  has_many :orders

  field :name
  field :description
  field :items_count,     type: Integer, default: 0
  field :active,          type: Boolean, default: true
  field :category_slug,   type: String,  default: "recent"
  field :max_products,    type: Integer, default: 5
  field :partner,         type: String,  default: "customagic"

  slug :name

  index({slug: 1, category_slug: 1})

end