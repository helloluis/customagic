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
    if @current_shop
      "shop shop_#{@current_shop.color_scheme}"
    else
      ""
    end
  end
    
end
