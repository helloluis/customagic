require 'ostruct'

# settings = YAML.load_file Rails.root.join("config/settings/environments/#{Rails.env}.yml")
# Dir[Rails.root.join("config/settings/*.yml")].each do |file|
#   settings.merge!({ File.basename(file, '.yml') => YAML.load_file(file)[Rails.env] })
# end

#App = Hashie::Mash.new(settings)
App = Hashie::Mash.new

App.name = "Customagic"
App.partner_name = "customagic"
App.url = Rails.env.development? ? "customagic.xxx" : "customagic.ph"
App.default_item_type = "shirt"

App.facebook = {
  id: "700564963290007",
  secret: "9a3121de3121af4e42bcc22384030fe3" 
}

App.item_types = [
  {
    name: "Shirt",
    slug: "shirt",
    default: true,
    default_colors: [ "ffffff", "000000", "330000" ],
    item_styles: [
      { name: "Basic Tees", 
        slug: "basic",
        image: "",
        sub_styles: [
          { name: "Standard Tagless Tee",
            slug: "basic_standard", 
            description: "Budget friendly", 
            image: "",
            min_order: 20 },
          { name: "Canvas Ringspun Tee",  
            slug: "basic_canvas",
            description: "Premium materials", 
            image: "",
            min_order: 20 },
          { name: "American Apparel Crew",  
            slug: "basic_american",
            description: "Brand quality", 
            image: "",
            min_order: 20 }
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