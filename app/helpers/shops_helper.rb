module ShopsHelper
  
  def summarize_prices(product, currency_symbol=false)
    if product.hide_prices? || !product.price_variants || product.price_variants.empty?
      str = "Contact for Prices"
    else
      if product.price_variants.length > 1 && !product.price_variants_have_same_price?
        str = "<span>Starts at #{currency_symbol||product.shop.currency_symbol}#{number_with_precision(product.lowest_price_with_discount, :precision => 2, :delimiter => ',')}</span>"
      else
        str = "#{currency_symbol||product.shop.currency_symbol}#{number_with_precision(product.lowest_price_with_discount, :precision => 2, :delimiter => ',')}"
      end
      if product.is_discounted?
        str += " (#{product.discount.round}% off!)"
      end
    end
    str
  end

  def summarize_variants(product, wrap)
    return "" if product.price_variants.length==1

    num_pri = product.price_variants.map{|pv| pv['primary']}.uniq.reject{|pp|pp.blank?}.length
    num_sec = product.price_variants.map{|pv| pv['secondary']}.uniq.reject{|pp|pp.blank?}.length

    arr = [ pluralize(num_pri, product.price_variant_classes['primary']) ]
    arr << pluralize(num_sec, product.price_variant_classes['secondary']) if num_sec > 0

    return wrap ? "(Available in #{arr.join(" and ")})" : "Available in #{arr.join(" and ")}"
  end

  def humanize_cart_item(cart_item)
    if (cart_item[:availability]==false) 
      cart_item['formatted_subtotal'] = @current_shop.currency_symbol + number_with_precision(0,:precision =>2)
      cart_item['subtotal'] = number_with_precision(0,:precision =>2)
      cart_item['quantity'] = 0
      cart_item['variant_stock'] = 0
    else
      cart_item['formatted_subtotal'] = @current_shop.currency_symbol + number_with_precision(cart_item['price'].to_s.gsub(',','').to_f * cart_item['quantity'].to_i, :precision => 2, :delimiter => ',')
      cart_item['subtotal'] = number_with_precision(cart_item['price'].to_s.gsub(',','').to_f * cart_item['quantity'].to_i, :precision => 2)
    end
    cart_item['formatted_price'] = @current_shop.currency_symbol + number_with_precision(cart_item['price'].to_s.gsub(',','').to_f, :precision => 2, :delimiter => ',')
    cart_item['currency'] = @current_shop.currency_symbol
    cart_item['price'] = number_with_precision(cart_item['price'].to_s.gsub(',','').to_f, :precision => 2)
    cart_item
  end

  def cart_with_info(shop,cart)
    return {} unless cart
    nice_cart = {discount_code: cart.discount_code, contents: {}}
    if cart.contents && cart.contents.keys.any?
      cart.contents.each do |k,hash|
        if hash['item_id'] && (product = shop.products.find(hash['item_id']))
          nice_cart[:contents][k] = humanize_cart_item(hash.merge(product.attributes_for_cart).merge(:availability => product.has_available_variant?(hash['variant_name'],cart,0)))
        end
      end
    end
    nice_cart
  end

  def most_popular_item
    if item_slug_and_num = @current_shop.most_popular_item(100)
      if item = @current_shop.products.find(item_slug_and_num[0])
        return "<a href='#{site_product_url(current_site, item.slug)}'>#{item.name}</a> #{item_slug_and_num[1]}"
      else
        return ":_("
      end
    else
      return ":("
    end
  end

  def order_summary(orders)
    num_pending    = orders.find_all{|o|o.status==0}.count
    num_processing = orders.find_all{|o|o.status==1}.count
    num_shipping   = orders.find_all{|o|o.status==2}.count
    num_fulfilled  = orders.find_all{|o|o.status==3}.count
    num_cancelled  = orders.find_all{|o|o.status==4}.count
    num_rejected   = orders.find_all{|o|o.status==5}.count

    sentence = []

    if orders.length > 0
      sentence << "#{orders.length} recent"
    end

    if num_pending > 0 
      sentence << link_to("#{num_pending} pending", "/orders?status=0").html_safe 
    end

    if num_processing > 0 
      sentence << link_to("#{num_processing} processing", "/orders?status=1").html_safe 
    end

    if num_shipping > 0 
      sentence << link_to("#{num_shipping} shipping", "/orders?status=2").html_safe 
    end

    if num_cancelled > 0 
      sentence << link_to("#{num_cancelled} cancelled", "/orders?status=5").html_safe 
    end

    if num_rejected > 0 
      sentence << link_to("#{num_rejected} rejected", "/orders?status=5").html_safe 
    end

    if sentence.any?
      sentence.join(", ").html_safe
    else
      ""
    end
  end

  def summarize_product_description(description, length=800)
    begin
      desc = description.gsub(/<br\s*[\/]?>/i,'\n').gsub(/\\n+/,'\n')
      simple_format(auto_link(truncate(strip_tags(desc).gsub(/\\n/,'&nbsp;'), :length => length)))
    rescue
      ""
    end
  end

  def render_album_thumbnail(album)
    thumbs = []
    i = 0
    attempts = 0
    while thumbs.length<album.products.length && thumbs.length<4 && attempts<20 do
      unless album.products[i].last.blank?
        thumbs << content_tag(:div,"",:class=>"album_inner_thumb",:style=>"background-image:url(#{album.products[i].last})")
        i+=1
      end
      attempts+=1
    end
    content_tag(:div, thumbs.join("").html_safe,:class=>"album_thumbnail album_thumb_#{thumbs.length ? thumbs.length : '1'}")
  end

  def product_premium_class(product)
    if product.shop.site.is_free?
      "product_free"
    else
      if product.shop.site.plan.free_domain?
        "product_premium"
      else
        "product_paid"
      end
    end
  end

  def product_in_collection(product, collections)
    matched_collections = []
    collections.each do |collection|
      if collection.products.map{|p| p.first}.include?(product._id.to_s)
        matched_collections << collection
      end
    end
    
    if matched_collections.any?
      p = content_tag(:p, "This product can be found in these collections:")
      lis = []
      matched_collections.map do |mc| 
        lis << content_tag(:li, (link_to(mc.name, "/albums/#{mc.slug}", :class => "tag") + " (#{mc.products.length})").html_safe)
      end
      ul = content_tag(:ul, lis.join("").html_safe, :class => "nolist")
      content_tag(:div, (p + ul).html_safe, :class => "found_in_collections clearfix")
    end
  end

  def product_is_in_collection?(product,collections)
    matched_collections = []
    collections.each do |collection|
      if collection.products.map{|p| p.first}.include?(product._id.to_s)
        matched_collections << collection
      end
    end
    matched_collections.any? ? matched_collections.first : false
  end

  def can_moderate_content?
    current_user && current_account && current_user.is_account_owner?(current_account)
  end

  def marketplace_categories(sort_by_name=false)
    if sort_by_name
      MarketplaceCategory.where(:visible=>true).asc(:name).map{|mc| [mc.name,mc.slug]}
    else
      MarketplaceCategory.where(:visible=>true).asc(:sort).map{|mc| [mc.name,mc.slug]}
    end
  end

  def marketplace_category_thumbnails(num_big=6, current_category=false, alphabetical=false)
    html = ""
    @cats = MarketplaceCategory.where(:visible=>true,:partner =>current_partner.short)
    if alphabetical
      @cats = @cats.asc(:name)
    else
      @cats = @cats.asc(:priority) #sort{|a,b|b.products.length<=>a.products.length}
    end
  
    @cats.each_with_index do |mc,i|
      if i<num_big
        div_of_thumbs = content_tag(:ul, marketplace_category_thumbnail(mc), :class => "marketplace_category_thumbs nolist")
        html << content_tag(:li, link_to(div_of_thumbs, "/marketplace/#{mc.slug}") + link_to(mc.name, "/marketplace/#{mc.slug}", :class => "marketplace_category_title"), :class => "marketplace_category category_#{mc.slug} #{current_category==mc.slug ? 'current_category' : ''}")
      else
        html << content_tag(:li, link_to(mc.name.titleize, "/marketplace/#{mc.slug}"), :class => "marketplace_category marketplace_category_title marketplace_category_text category_#{mc.slug} #{current_category==mc.slug ? 'current_category' : ''}")
      end
    end
    return html.html_safe
  end

  def marketplace_category_thumbnail(mc, num_thumbs=4)
    lis = []
    Product.where(:featured_in_marketplace=>true, :category_slug=>mc.slug).desc(:created_at).limit(num_thumbs).each do |product|
      lis << content_tag(:li, "", :class => "product_thumb", :style => "background-image:url(#{product.primary_image})", :title => product.name)
    end
    lis.join(" ").html_safe
  end

  def total_inventory(shop)
    shop.products.only(:available_stock).map(&:available_stock).sum
  end

  # caches the site records related with a given set of products
  def retrieve_sites_for_products(products)
    return [] unless products.any?
    shop_ids = products.map(&:shop_id).uniq
    site_ids = Shop.only(:site_id, :currency).find(shop_ids).map(&:site_id) #each do |shop|
    return Site.only(:title, :subdomain, :domain, :favicon, :url, :public_url, :plan_type, :unsuccessful_payment).find(site_ids).entries
  end

  # matches the product with the approriate site record
  def find_site_for_product(product, sites)
    sites.find{|s| s._id==product.shop.site_id}
  end

  def discount_code_value(shop, code)
    return "" if code.code_type.blank?
    str = case code.code_type
      when "percentage"
        "<strong>#{code.percentage}%</strong> off"
      when "absolute"
        "<strong>#{shop.currency_symbol}#{number_with_precision(code.absolute, :precision=>2)}</strong> off"
      when "free_shipping"
        "Free Shipping"
    end
    str << " on purchases over <strong>#{shop.currency_symbol}#{number_with_precision(code.threshold, :precision=>2)}</strong>" if code.threshold.to_f > 0
    str << " on any purchase" if code.threshold.to_f==0
    str
  end

  def official_referral_link(site)
    link_to official_referral_url(site), official_referral_url(site)
  end

  def official_referral_url(site)
    "http://#{app_url}/for/#{site.subdomain}"
  end

  def get_or_set_guest_session
    unless current_user && current_account && current_user.is_account_owner_of?(current_account)
      unless cookies[:guest_id].blank?
        @guest = cookies[:guest_id]
      else
        @guest = Digest::MD5.hexdigest(Time.now.to_s)
        cookies[:guest_id] = {
          :value => @guest,
          :expires => 1.day.from_now
        }
      end
    end
  end

  def get_or_set_cart
    return false unless @shop
    unless @cart = @shop.find_cart_for_guest(@guest)
      @cart = @shop.carts.create(guest_id: @guest)
    end
  end

  def formatted_earnings_threshold
    "#{@current_shop.currency_symbol}#{number_with_precision(current_site.plan.earnings_threshold_php,:precision=>2,:delimiter=>",")}"
  end

  def earnings_threshold_dashboard_message(site)
    str = false
    return str unless site.shop
    
    if site.recently_created? && !site.shop.just_made_first_sale? && !site.is_above_earnings_threshold?

      str = content_tag(:h1, "Welcome to your #{app_name.titleize} Dashboard!")
      str += content_tag(:p, "Please look around and make yourself at home. If you have any questions, don't hesitate <a href='#!' class='feedback'>to drop us a note</a>!".html_safe)
    
    elsif site.shop && site.shop.just_made_first_sale?

      str = content_tag(:h1, "Hey, you've just made your very first sale!")
      str += content_tag(:p, "Congratulations! We're super #{app_name.titleize} for you! (Remember, your first #{formatted_earnings_threshold} worth of sales is completely free of any transaction fees from us.)".html_safe)

    elsif site.is_approaching_earnings_threshold?

      str = content_tag(:h1, "Awesome! You're almost at #{formatted_earnings_threshold} in sales!".html_safe)
      str += content_tag(:p, "Remember, after your first #{formatted_earnings_threshold} in sales, you will need to add your credit card details in order to continue using your shop.".html_safe)

    elsif site.is_above_earnings_threshold?

      if site.is_approaching_end_of_grace_period?

        str = content_tag(:h1, "You need to add your credit card to keep your site open".html_safe)
        str += content_tag(:p, "Your site will only stay active until #{site.end_of_grace_period.strftime('%d %B %Y %H:%M')}, after which it will be deactivated. Please enter your credit card information before then to ensure an uninterrupted experience.".html_safe)

      elsif site.is_in_middle_of_grace_period?

        str = content_tag(:h1, "Don't forget to add your credit card info!")
        str += content_tag(:p, "Now that your sales have exceeded #{formatted_earnings_threshold}, you will need to enter your credit card information in order to continue using your shop. Don't worry, you won't be billed until #{site.next_invoice.strftime('%d %B %Y')}".html_safe)

      else

        str = content_tag(:h1, "Wow! You've passed #{formatted_earnings_threshold} in sales!".html_safe)
        str += content_tag(:p, "Congratulations, your sales have exceeded #{formatted_earnings_threshold}! Your shop is now eligible to be featured on our homepage, and can use <a href='/help#help_domains'>a third-party domain name</a>. Please <a href='#upgrade' class='show_upgrade_dialog'>enter your credit card details now</a> to ensure an uninterrupted #{app_name.titleize} experience.".html_safe)

      end

    end
    str
  end

  def greetings

    str = [ "Hello!",
            "Hallo!",
            "Howdy!",
            "Ahoy!",
            "Ahoy there!",
            "Kamusta!",
            "Good day!",
            "G'Day!",
            "Greetings!",
            "Nice to see you again!",
            "Great to see you back!",
            "Glad to see you back!",
            "Welcome back!",
            "Hey there!",
            "Hello there!",
            "Happy to see you!",
            "How's it going?",
            "How're things going?",
            "How are you doing today?" ].sample

    time = Time.now.in_time_zone(current_site.time_zone)
    hour = time.hour

    if hour>=0 && hour<6
      if rand(3)>1
        str = [ "Hello! Burning the midnight oil?",
                "Hooray for night owls!",
                "Working late tonight, huh? :)",
                "It's always easier to work when everyone else is asleep.",
                "It's nice and quiet here tonight." ].sample 
      end
    elsif hour>=6 && hour<9
      if rand(3)>1
        str = [ "Early birds get the job done!", 
                "Good morning, sleepyhead!",
                "Wow it's early!"
              ].sample
      end
    elsif hour>=13 && hour<18
      str = "Good afternoon!" if rand(3)>1
        
    elsif hour>=19 && hour<21
      if rand(3)>1
        str = [ "Good evening!", 
                "Had a good dinner?"
              ].sample
      end
    end

    str
  end

end
