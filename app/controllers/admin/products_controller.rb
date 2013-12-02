class Admin::ProductsController < Admin::BaseController

  include ApplicationHelper
  #include SitesHelper
  before_filter :set_product, :only => [ :toggle_feature, :toggle_visibility, :update_category ]

  # add_crumb("Products") { |instance| instance.send :products_path }

  respond_to :js, :html, :json

  def index
    @page_title = "Products"
    @only = 'products'
    if is_infinitely_admin?
      @products_count = Product.where(:status.ne => 9).count
      @featured_products_count = Product.where(:featured_in_marketplace => true).count
      @products = Product.where(:status.ne => 9) #.desc(:created_at)
    elsif current_partner.has_marketplace?
      @products_count = Product.where(:status.ne => 9, :partner=>current_partner.short).count
      @featured_products_count = Product.where(:featured_in_marketplace => true, :partner=>current_partner.short).count
      @products = Product.where(:status.ne => 9, :partner=>current_partner.short) #.desc(:created_at)
    end

    sort_by = params[:sort_by] ||= :created_at
    sort_dir = params[:sort_dir] ||= :desc

    if params[:sort_by]
      @products = @products.order_by([sort_by.to_sym, sort_dir.to_sym])
    else
      @products = @products.order_by([:created_at, :desc])
    end

    @products = @products.page(params[:page]).per(params[:per]||100) #Kaminari.paginate_array(@products).page(params[:page]).per(params[:per] || 100)
    respond_with @products
  end

  def toggle_feature
    @product.toggle!(:featured_in_marketplace)
    respond_with @product
  end

  def toggle_visibility
    @product.toggle!(:visible_in_marketplace)
    respond_with @product
  end

  def update_category
    @product.category_slug = params[:product][:category_slug]
    @product.save(:validate=>false)
    respond_with @product.reload
  end

  protected

    def set_product
      @product = Product.find(params[:product_id])
    end

end