module ProductsHelper

  def countdown(product)
    if product.availability_start && Time.now < product.availability_start+product.campaign_length.days
      t_then = product.availability_start + product.campaign_length.days
      t_now = Time.now
      return Time.diff(t_then, t_now, "<span>%d</span> days <span>%h</span> hours <span>%m</span> mins <span>%s</span> secs")[:diff] + " left"
    else
      return 0
    end
  end
end