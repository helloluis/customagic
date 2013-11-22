module Characteristics
  extend ActiveSupport::Concern

  included do
    
    field :product_type,        default: "shirt" 
    field :product_style,       default: "basic"
    field :product_sub_style,   default: "basic_standard"
    field :color,               type: String,   default: "#ffffff"

  end

  def product_type_object
    App.product_types.find{|pt|pt.slug==product_type}
  end

  def product_style_object
    product_type_object.product_styles.find{|ps| ps.slug==product_style}
  end

  def product_sub_style_object
    product_style_object.sub_styles.find{|pss| pss.slug==product_sub_style}
  end

  def base_price
    product_sub_style_object.prices.first.last
  end

end