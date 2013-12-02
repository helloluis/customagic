class Admin::ShopsController < Admin::BaseController

  include ApplicationHelper
  # include SitesHelper
  # before_filter :set_product, :only => [ :toggle_feature, :toggle_visibility, :update_category ]

  #add_crumb("Shop Earnings") { |instance| instance.send :shops_path }

  respond_to :js, :html, :json

  def index
    @page_title = "Shop Earnings"

    if is_infinitely_admin? 
      @shops = Shop.all
    elsif current_partner.has_marketplace?
      @shops = Shop.where(partner: current_partner.short)  
    end   

    sort_by = params[:sort_by] ||= :created_at
    sort_dir = params[:sort_dir] ||= :desc

    if params[:sort_by]
      @shops = @shops.order_by([sort_by.to_sym, sort_dir.to_sym])
    else
      @shops = @shops.order_by([:created_at, :desc])
    end

    @shops = @shops.page(params[:page]).per(params[:per]||30) #Kaminari.paginate_array(@products).page(params[:page]).per(params[:per] || 100)
    respond_with @shops
  end

  protected

    def set_order
      @order = Order.find(params[:order_id])
    end

end