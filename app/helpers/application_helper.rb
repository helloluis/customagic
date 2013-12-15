module ApplicationHelper

  def app_name
    App.name
  end

  def app_partner_name
    App.partner_name
  end

  def app_default_product_type
    App.default_product_type
  end

  def app_facebook_id
    App.facebook.id
  end

  def app_url
    App.url
  end

  def app_currency_label
    App.currency.label
  end

  def app_currency_symbol
    App.currency.symbol
  end

  def base_price_for_units(sub_style, num)
    sub_style.prices.find{|prices| prices.first.to_a.include?(num.to_i)}.last #rescue 0
  end


  def document_title
    @page_title || "Welcome to #{app_name}"
  end

  def document_meta

  end
  
  def is_owner?(shop)
    user_signed_in? && shop && current_user.shop==shop
  end

  def body_classes
    classes = "#{mobile_browser? ? 'mobile_browser' : ''} clearfix"
    if @current_shop
      classes += " shop shop_#{@current_shop.color_scheme}"
    else
      classes += ""
    end
    classes
  end

  def edit_product_path(shop, product)
    "/#{shop.slug}/products/#{product.slug}/edit"
  end

  def edit_product_info_path(shop, product)
    "/#{shop.slug}/products/#{product.slug}/edit_info"
  end

  def number_to_ordinal(num)
    num = num.to_i
    if (10...20)===num
    "#{num}th"
    else
    g = %w{ th st nd rd th th th th th th }
    a = num.to_s
    c=a[-1..-1].to_i
    a + g[c]
    end
  end

    
end
