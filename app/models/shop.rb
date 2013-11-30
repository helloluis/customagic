class Shop

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Slug

  belongs_to :user
  has_many :albums
  has_many :products do
    def orderable
      where(status: 2)
    end
  end
  has_many :orders
  has_many :assets
  has_many :images

  field :name,            type: String,  default: "New Shop"
  field :color_scheme,    type: String,  default: "light"
  field :website
  field :description
  
  field :paypal_email

  field :twitter
  field :facebook
  field :instagram
  field :pinterest
  field :googleplus

  field :items_count,     type: Integer, default: 0
  field :active,          type: Boolean, default: true
  field :category_slug,   type: String,  default: "recent"
  field :max_products,    type: Integer, default: 5
  field :partner,         type: String,  default: "inkify"
  field :status,          type: Integer, default: 1 # 1 = active, 2 = suspended, 3 = hidden
  field :time_zone,       type: String,  default: "Singapore"

  field :gcash_name
  field :gcash_number

  validates_presence_of :name
  validates_uniqueness_of :name

  mount_uploader :attachment, LogoAttachment

  slug :name

  index({slug: 1, category_slug: 1})

  def currency_symbol
    "PHP"
  end

  def as_json(options = {})
    super(options.reverse_merge(:methods => [:slug, :currency_symbol]))
  end

  def can_transact?
    status==1
  end

end