class ProductReview

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :shop
  belongs_to :product

end