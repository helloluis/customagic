module ApplicationHelper

  def app_name
    App.name
  end

  def app_partner_name
    App.partner_name
  end

  def app_default_item_type
    App.default_item_type
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

  def document_title
    @page_title || "Welcome to #{app_name}"
  end

  def document_meta

  end
  
end
