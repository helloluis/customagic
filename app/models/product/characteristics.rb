class Product
  module Characteristics
    extend ActiveSupport::Concern

    included do
      
      field :product_type,         default: "shirt" 
      field :product_style,        default: "basic"
      field :product_sub_style,    default: "basic_standard"
      field :color,                type: String,   default: "#ffffff"
      field :final_art_dimensions, type: Array, default: [0,0]
      field :mockup_dimensions,    type: Array, default: [0,0]
      #before_save :set_pricing
    end

    def remaining
      sales_goal-num_orders
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
      product_sub_style_object.highest_production_price
    end
    
    def update_sales_information!
      self.base_price = product_sub_style_object.highest_production_price
      hash = []
      product_style_object.sizes.each do |psize|
        hash << { primary: psize, secondary: "", quantity: 1000000, price: buy_now_price }
      end
      self.price_variants = hash
      self.save
    end

    def production_price_steps
      (product_sub_style_object.highest_production_price-product_sub_style_object.lowest_production_price)/product_sub_style_object.delta
    end

    def production_cost
      hp  = product_sub_style_object.highest_production_price
      lp  = product_sub_style_object.lowest_production_price
      del = product_sub_style_object.delta

      [hp-(num_orders*del),lp].max
    end

  end
end