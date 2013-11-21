module ApplicationHelper

  def app_name
    App.name
  end

  def app_default_item_type
    App.default_item_type
  end

  def app_facebook_id
    App.facebook_id
  end

  def app_url
    App.url
  end

  def document_title
    @page_title || "Welcome to #{app_name}"
  end

  def document_meta

  end
  
end
