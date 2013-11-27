module ProductsHelper

  def countdown(product)
    if product.availability_start && Time.now < product.availability_start+product.campaign_length.days
      return Time.diff(product.availability_start + product.campaign_length.days, Time.now, '%d %hh %mm %ss')[:diff] + " left"
    else
      return 0
    end
  end
end