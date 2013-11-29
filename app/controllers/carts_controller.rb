class CartsController < ApplicationController
  
  include ShopsHelper  
  include ActionView::Helpers::NumberHelper
  before_filter :authenticate_user!
  before_filter :set_shop
  before_filter :set_cart
  before_filter :set_product, only: [ :add_product, :remove_product ]
  
  def index
    respond_to do |format|
      format.html do
        @order = current_site.shop.orders.new
        if mobile_request?
          @with_iframe = true
          render :layout => "mobile_shops", :template => "carts/show_mobile" 
        else
          render :layout => "shops"
        end
      end
      format.json do
        @cart_with_info = cart_with_info(@shop, @cart)
        render :json => @cart_with_info, :callback => params[:callback]
      end
    end
  end

  def add_product
    logger.info "!! #{@shop.can_transact?} #{@product.is_orderable?}"
    if @product.is_orderable?
      @cart.add_to_cart(@product, params[:name], @preorder ? @product.group_price : @product.buy_now_price, current_shop.currency_symbol, params[:quantity])
      @cart.save
      @order = @cart.build_order
    else
      flash.now[:alert] = "That product is not available."
    end
    render :action => :show
  end

  def remove_product
    @cart.remove_from_cart(params[:product_id], params[:quantity])
    @cart.save
    @cart.reload
    render :action => :show
  end

  protected

    def set_shop
      @current_shop = @shop = Shop.find(params[:shop_id])
    end

    def set_cart
      @cart = current_user.find_or_create_cart
    end

    def set_product
      @product = @current_shop.products.find(params[:product_id])
    end

end