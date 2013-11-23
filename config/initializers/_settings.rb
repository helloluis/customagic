require 'ostruct'

settings = YAML.load_file Rails.root.join("config/settings/environments/#{Rails.env}.yml")
Dir[Rails.root.join("config/settings/*.yml")].each do |file|
  settings.merge!({ File.basename(file, '.yml') => YAML.load_file(file)[Rails.env] })
end

App = Hashie::Mash.new(settings)

App.name = "Customagic"
App.partner_name = "customagic"
# App.uri = URI::HTTP.build(host: host, port: port.try(:to_i))
App.url = Rails.env.development? ? "customagic.xxx" : "customagic.ph"
App.default_product_type = "shirt"

App.fonts = {
  helvetica: "Helvetica",
  lucida_sans: "Lucida Sans",
  times_new_roman: "Times New Roman",
  courier: "Courier"
}

App.facebook = {
  id: "700564963290007",
  secret: "9a3121de3121af4e42bcc22384030fe3" 
}

App.currency = {
  symbol: "&#8369;",
  label: "PhP"
}

App.product_types = [
  {
    name:           "Shirt",
    slug:           "shirt",
    default:        true,
    colors:         [ "#ffffff", "#000000", "#003366", "#666666", "#551100" ],
    sides:          [ 
      { name: "Front", slug: "front", dimensions: [ 46, 71 ], editable_area: [ 21, 29.7 ] },
      { name: "Back",  slug: "back",  dimensions: [ 46, 71 ], editable_area: [ 21, 29.7 ] }
      ],
    dpi_target:     118, # per cm
    product_styles: [
      { name: "Basic Tees", 
        slug: "basic",
        image: "",
        color_images: [ 
          "mens_crew_ffffff.jpg", 
          "mens_crew_000000.jpg", 
          "mens_crew_003366.jpg", 
          "mens_crew_666666.jpg", 
          "mens_crew_551100.jpg"
        ],
        sub_styles: [
          { name: "Standard Tagless Tee",
            slug: "basic_standard", 
            description: "Budget friendly", 
            image: "shirt_thumb.png",
            min_order: 20,
            prices: [
              [ 1..5,   300 ],
              [ 6..20,  290 ],
              [ 21..50, 270 ],
              [ 51..100, 250 ],
              [ 101..300, 220 ],
              [ 301..1000, 200 ],
              [ 1001..5000, 165 ]
            ] 
          },
          { name: "Canvas Ringspun Tee",  
            slug: "basic_canvas",
            description: "Premium materials", 
            image: "shirt_thumb.png",
            min_order: 20,
            prices: [
              [ 1..5,   350 ],
              [ 6..20,  340 ],
              [ 21..50, 310 ],
              [ 51..100, 300 ],
              [ 101..300, 270 ],
              [ 301..1000, 250 ],
              [ 1001..5000, 215 ]
            ]  },
          { name: "American Apparel Crew",  
            slug: "basic_american",
            description: "Brand quality", 
            image: "shirt_thumb.png",
            min_order: 20,
            prices: [
              [ 1..5,   400 ],
              [ 6..20,  390 ],
              [ 21..50, 370 ],
              [ 51..100, 350 ],
              [ 101..300, 320 ],
              [ 301..1000, 300 ],
              [ 1001..5000, 265 ]
            ]  }
        ]
      },
      # { name: "Women's Relaxed Fit", slug: "womens_relaxed" },
      # { name: "Women's Slim Fit", slug: "womens_slim" },
      # { name: "Long-sleeved", slug: "long_sleeved" },
      # { name: "Tank Tops", slug: "tank_tops" },
      # { name: "V-Neck Tees", slug: "v_neck_tees" }
    ],
  }
]