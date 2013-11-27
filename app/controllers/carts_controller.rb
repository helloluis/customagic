class CartsController
  
  before_filter :authenticate_user!
  before_filter :set_shop
  before_filter :set_cart
  before_filter :set_product

  def add_product
    if params[:preorder]
      @preorder = true
    else
      @buy_now = true
    end
    if @product.is_orderable?
      if @product.has_available_variant?(params[:name],@cart,1)
        @cart.add_to_cart(@product, params[:name], params[:price], current_site.shop.currency, params[:quantity])
        @cart.save
      else
        @error = "That product variant only has #{@product.available_stock_for_variant(params[:name])} units available."
      end
    else
      @error = "That product is not available."
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
      @cart = current_user.carts.active
    end

    def set_product
      @product = @current_shop.products.find(params[:product_id])
    end

end