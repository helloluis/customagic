require 'ostruct'

settings = YAML.load_file Rails.root.join("config/settings/environments/#{Rails.env}.yml")
Dir[Rails.root.join("config/settings/*.yml")].each do |file|
  settings.merge!({ File.basename(file, '.yml') => YAML.load_file(file)[Rails.env] })
end

App = Hashie::Mash.new(settings)

App.name = "Inkify"
App.partner_name = "inkify"
# App.uri = URI::HTTP.build(host: host, port: port.try(:to_i))
App.url = Rails.env.development? ? "inkify.xxx" : "inkify.me"
App.default_product_type = "shirt"

App.support_email = "departmentofink@gmail.com"

App.fonts = {
  helvetica: "Helvetica",
  lucida_sans: "Lucida Sans",
  times_new_roman: "Times New Roman",
  courier: "Courier"
}

App.currency = {
  symbol: "&#8369;",
  label: "PHP"
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
        sizes: %w(small medium large x-large xx-large),
        sub_styles: [
          { name: "Men/Unisex Crew",
            slug: "basic_standard", 
            description: "Organic cotton, round-neck", 
            image: "shirt_thumb.png",
            buy_now_price: 500,
            minimum_favorites: 100,
            production_price: 300
          }
          # { name: "Premium Tee",
          #   slug: "basic_premium",
          #   description: "Premium 100% cotton", 
          #   image: "shirt_thumb.png",
          #   buy_now_price: 750,
          #   highest_production_price: 600,
          #   lowest_production_price: 350,
          #   production_costs: [
          #     [0,   600],
          #     [5,   550],
          #     [20,  500],
          #     [50,  450],
          #     [100, 400],
          #     [250, 350]
          #   ]
          # }
          # { name: "American Apparel Crew",  
          #   slug: "basic_american",
          #   description: "Brand quality", 
          #   image: "shirt_thumb.png",
          #   min_order: 20,
          #   buy_now_price: 800,
          #   # prices: [
          #   #   [ 1..5,   300 ],
          #   #   [ 6..20,  290 ],
          #   #   [ 21..50, 270 ],
          #   #   [ 51..100, 250 ],
          #   #   [ 101..300, 220 ],
          #   #   [ 301..1000, 200 ],
          #   #   [ 1001..5000, 165 ]
          #   # ]  
          # }
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

App.charities = [
  { name: "Philippine Red Cross", url: "http://redcross.org.ph", email: 'prc@redcross.org.ph' }
]

App.shipping_costs = [
  { name: "Metro Manila",       slug: "metro-manila",      individual_cost: 80,     group_cost: 10  },
  { name: "Luzon",              slug: "luzon",             individual_cost: 140,    group_cost: 10  },
  { name: "Visayas",            slug: "visayas",           individual_cost: 140,    group_cost: 10  },
  { name: "Mindanao",           slug: "mindanao",          individual_cost: 140,    group_cost: 10  },
  { name: "Australia",          slug: "australia",         individual_cost: 1210,   group_cost: 336 },
  { name: "Austria",            slug: "austria",           individual_cost: 1498,   group_cost: 405 },
  { name: "Bahrain",            slug: "bahrain",           individual_cost: 1668,   group_cost: 350 },
  { name: "Bangladesh",         slug: "bangladesh",        individual_cost: 1280,   group_cost: 321 },
  { name: "Belarus",            slug: "belarus",           individual_cost: 2701,   group_cost: 840 },
  { name: "Belgium",            slug: "belgium",           individual_cost: 1668,   group_cost: 350 },
  { name: "Bhutan",             slug: "bhutan",            individual_cost: 2701,   group_cost: 840 },
  { name: "Brazil",             slug: "brazil",            individual_cost: 1882,   group_cost: 825 },
  { name: "Brunei",             slug: "brunei",            individual_cost: 800,    group_cost: 173 },
  { name: "Bulgaria",           slug: "bulgaria",          individual_cost: 2701,   group_cost: 840 },
  { name: "Cambodia",           slug: "cambodia",          individual_cost: 1432,   group_cost: 381 },
  { name: "Canada",             slug: "canada",            individual_cost: 1432,   group_cost: 378 },
  { name: "China",              slug: "china",             individual_cost: 1210,   group_cost: 202 },
  { name: "Cyprus",             slug: "cyprus",            individual_cost: 1626,   group_cost: 379 },
  { name: "Denmark",            slug: "denmark",           individual_cost: 1432,   group_cost: 398 },
  { name: "Egypt",              slug: "egypt",             individual_cost: 1717,   group_cost: 350 },
  { name: "Fiji",               slug: "fiji",              individual_cost: 1668,   group_cost: 350 },
  { name: "Finland",            slug: "finland",           individual_cost: 1498,   group_cost: 406 },
  { name: "France",             slug: "france",            individual_cost: 1641,   group_cost: 397 },
  { name: "Germany",            slug: "germany",           individual_cost: 1514,   group_cost: 467 },
  { name: "Great Britain",      slug: "great-britian",     individual_cost: 1341,   group_cost: 496 },
  { name: "Greece",             slug: "greece",            individual_cost: 1687,   group_cost: 353 },
  { name: "HongKong",           slug: "hongkong",          individual_cost: 800,    group_cost: 179 },
  { name: "Hungary",            slug: "hungary",           individual_cost: 1668,   group_cost: 350 },
  { name: "Iceland",            slug: "iceland",           individual_cost: 2701,   group_cost: 840 },
  { name: "India",              slug: "india",             individual_cost: 1280,   group_cost: 242 },
  { name: "Indonesia",          slug: "indonesia",         individual_cost: 800,    group_cost: 229 },
  { name: "Iran",               slug: "iran",              individual_cost: 2701,   group_cost: 840 },
  { name: "Ireland",            slug: "ireland",           individual_cost: 1280,   group_cost: 442 },
  { name: "Israel",             slug: "israel",            individual_cost: 1722,   group_cost: 518 },
  { name: "Italy",              slug: "italy",             individual_cost: 1568,   group_cost: 377 },
  { name: "Japan",              slug: "japan",             individual_cost: 1008,   group_cost: 238 },
  { name: "Jordan",             slug: "jordan",            individual_cost: 2701,   group_cost: 840 },
  { name: "Korea, South",       slug: "korea-south",       individual_cost: 1280,   group_cost: 321 },
  { name: "Kuwait",             slug: "kuwait",            individual_cost: 2701,   group_cost: 840 },
  { name: "Laos",               slug: "laos",              individual_cost: 1432,   group_cost: 381 },
  { name: "Luxembourg",         slug: "luxembourg",        individual_cost: 1668,   group_cost: 350 },
  { name: "Macau",              slug: "macau",             individual_cost: 1280,   group_cost: 321 },
  { name: "Malaysia",           slug: "malaysia",          individual_cost: 787,    group_cost: 216 },
  { name: "Maldives",           slug: "maldives",          individual_cost: 1280,   group_cost: 321 },
  { name: "Mongolia",           slug: "mongolia",          individual_cost: 2701,   group_cost: 840 },
  { name: "Myanmar",            slug: "myanmar",           individual_cost: 1280,   group_cost: 321 },
  { name: "Nepal",              slug: "nepal",             individual_cost: 2701,   group_cost: 840 },
  { name: "Netherlands",        slug: "netherlands",       individual_cost: 1499,   group_cost: 425 },
  { name: "New Zealand",        slug: "new-zealand",       individual_cost: 1136,   group_cost: 345 },
  { name: "Norway",             slug: "norway",            individual_cost: 1882,   group_cost: 401 },
  { name: "Oman",               slug: "oman",              individual_cost: 2701,   group_cost: 840 },
  { name: "Pakistan",           slug: "pakistan",          individual_cost: 1280,   group_cost: 321 },
  { name: "Papua New Guinea",   slug: "papua-new-guinea",  individual_cost: 1432,   group_cost: 381 },
  { name: "Poland",             slug: "poland",            individual_cost: 2701,   group_cost: 840 },
  { name: "Portugal",           slug: "portugal",          individual_cost: 2701,   group_cost: 840 },
  { name: "Qatar",              slug: "qatar",             individual_cost: 1468,   group_cost: 323 },
  { name: "Romania",            slug: "romania",           individual_cost: 2701,   group_cost: 840 },
  { name: "Russian Federation", slug: "russian-federation",individual_cost: 2701,   group_cost: 840 },
  { name: "Saudi Arabia",       slug: "saudi-arabia",      individual_cost: 1882,   group_cost: 364 },
  { name: "Singapore",          slug: "singapore",         individual_cost: 754,    group_cost: 195 },
  { name: "Slovenia",           slug: "slovenia",          individual_cost: 2701,   group_cost: 840 },
  { name: "Solomon Islands",    slug: "solomon-islands",   individual_cost: 2701,   group_cost: 840 },
  { name: "South Africa",       slug: "south-africa",      individual_cost: 2701,   group_cost: 840 },
  { name: "Spain",              slug: "spain",             individual_cost: 1354,   group_cost: 410 },
  { name: "Sri Lanka",          slug: "sri-lanka",         individual_cost: 1280,   group_cost: 321 },
  { name: "Sweden",             slug: "sweden",            individual_cost: 1789,   group_cost: 389 },
  { name: "Switzerland",        slug: "switzerland",       individual_cost: 1789,   group_cost: 420 },
  { name: "Taiwan",             slug: "taiwan",            individual_cost: 800,    group_cost: 179 },
  { name: "Thailand",           slug: "thailand",          individual_cost: 800,    group_cost: 204 },
  { name: "Turkey",             slug: "turkey",            individual_cost: 2701,   group_cost: 840 },
  { name: "Ukraine",            slug: "ukraine",           individual_cost: 2701,   group_cost: 840 },
  { name: "U.S.A.",             slug: "usa",               individual_cost: 1580,   group_cost: 537 },
  { name: "U.A.E.",             slug: "uae",               individual_cost: 1882,   group_cost: 358 },
  { name: "Vietnam",            slug: "vietnam",           individual_cost: 1280,   group_cost: 194 },
  { name: "Yemen",              slug: "yemen",             individual_cost: 2701,   group_cost: 840 }
]

App.mobile_devices = %w(
  palm
  blackberry
  nokia
  phone
  midp
  mobi
  symbian
  chtml
  ericsson
  minimo
  audiovox
  motorola
  samsung
  telit
  upg1
  windows\ ce
  ucweb
  astel
  plucker
  x320
  x240
  j2me
  sgh
  portable
  sprint
  docomo
  kddi
  softbank
  android
  mmp
  pdxgw
  netfront
  xiino
  vodafone
  portalmmm
  sagem
  mot-
  sie-
  ipod
  up.b
  webos
  amoi
  novarra
  cdm
  alcatel
  pocket
  ipad
  iphone
  mobileexplorer
  mobile
  maemo
  fennec
  silk
  playbook
)