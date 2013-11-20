module ApplicationHelper

  def app_name
    App.name
  end

  def app_default_item_type
    App.default_item_type
  end
  
end
