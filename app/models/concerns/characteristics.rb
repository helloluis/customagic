module Characteristics
  extend ActiveSupport::Concern

  included do
    
    field :product_type,        default: "shirt" 
    field :product_style,       default: "basic"
    field :product_sub_style,   default: "standard"
    field :color,               type: String,   default: "#ffffff"

  end
end