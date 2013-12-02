class CartsController < ApplicationController
  
  include ApplicationHelper
  include ShopsHelper  
  include ActionView::Helpers::NumberHelper
  before_filter :authenticate_user!
  before_filter :set_cart
  before_filter :set_product, only: [ :add_product, :remove_product ]
 
  def view
    @order = @cart.build_order unless @cart.order
    respond_to do |format|
      format.html { render :template => "carts/show" }
      format.json do 
        @cart_with_info = cart_with_info(@cart)
        render :json => @cart_with_info, :callback => params[:callback]
      end
    end
  end

  def add_product
    if @product.is_orderable?
      @cart.add_to_cart(@product, params[:name], @product.buy_now_price, app_currency_symbol, params[:quantity])
      @cart.save
      @order = @cart.build_order #unless @cart.order
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

  def empty
    @cart.empty!
    @cart.reload
    respond_to do |format|
      format.json { render :json => @cart.contents, :callback => params[:callback] }
    end
  end

  def update_cart
    
    if params[:c] && params[:c][:cc]
      
      content_params = params[:c][:cc]
      
      if content_params.keys.first.to_s=='0'
        massaged_content_params = {}
        content_params.each do |k,v|
          massaged_content_params[@cart.make_content_hash_key(v['item_id'],v['variant_name'])] = v
        end
      else
        massaged_content_params = content_params
      end
      
      @cart.write_attributes(contents: massaged_content_params)
      results = @cart.verify_availability_of_items
      logger.info "!! RESULTS #{results.inspect} !!"
      if results==[[],[]]
        @cart.write_attributes(shipping: params[:c][:shipping].gsub(',','').to_f, total: params[:c][:total].gsub(',','').to_f) if params[:c][:shipping] && params[:c][:total]
        @cart.save
        respond_to do |format|
          format.json do
            render :json => cart_with_info(@cart), :callback => params[:callback]
          end
        end
      else
        respond_to do |format|
          format.json do
            render :json => { error: results }, :callback => params[:callback]
          end
        end
      end
      
    else
      respond_to do |format|
        format.json do
          render :json => {}
        end
      end
    end
  end

  protected

    def set_cart
      @cart = current_user.find_or_create_cart
    end

    def set_product
      if params[:product_id]
        @product = Product.find(params[:product_id])
        @current_shop = @shop = @product.shop
      elsif @cart.contents

      end
    end

end