class CartsController < ApplicationController
  
  before_filter :authenticate_user!
  before_filter :set_shop
  before_filter :set_cart
  before_filter :set_product

  def add_product
    if params[:preorder] && @product.within_availability_period?
      @preorder = true
    else
      @buy_now = true
    end
    # logger.info "!! ORDERABLE #{@product.is_orderable?} !!"
    if @product.is_orderable?
      @cart.add_to_cart(@product, params[:name], @preorder ? @product.group_price : @product.buy_now_price, current_shop.currency_symbol, params[:quantity])
      @cart.save
      @order = @cart.build_order
    else
      @error = "That product is not available."
    end
    if @error
      flash.now[:alert] = @error
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