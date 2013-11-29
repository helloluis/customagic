class OrdersController < ApplicationController

  include ActionView::Helpers::NumberHelper

  before_filter :set_current_account_and_site
  before_filter :check_activation
  before_filter :authenticate_user!, :except => [ :create, :login_via_facebook ]
  before_filter :authorize_account_user!, :except => [ :create, :login_via_facebook ]
  before_filter :get_or_set_guest_session
  before_filter :set_shop
  before_filter :get_or_set_cart, :except => [ :index ]
  before_filter :set_order, :only => [ :show, :process, :fulfill, :unfulfill, :reject, :cancel ]

  layout "shops"

  def index
    @editor = true
    @sort   = params[:sort] || 'newest'
    @status = params[:status].blank? ? false : params[:status]
    @no_sidebar_tools = true

    @total_order_value = @shop.orders.total_alltime #@shop.orders.only(:total).any_in(:status => [0,1,2,3]).map(&:total).compact.sum
    @total_monthly_order_value = @shop.orders.total_since(30.days.ago)
    @total_order_value_with_shipping = @shop.orders.total_alltime_with_shipping
    @total_monthly_order_value_with_shipping = @shop.orders.total_with_shipping_since(30.days.ago)
    
    if @shop_asset = current_site.assets.shop
      
      @orders = @shop.orders

      if @q = params[:q]
        @orders = @orders.full_text_search(@q)
      end

      case @sort
        when 'newest'
          @orders = @orders.desc(:created_at)
        when 'oldest'
          @orders = @orders.asc(:created_at)
        when 'highest'
          @orders = @orders.desc(:total)
        when 'lowest'
          @orders = @orders.asc(:total)
        else
          @orders = @orders.desc(:created_at)
      end

      if @status
        if @status=='0' || @status=='6'
          @orders = @orders.or({:status => 0},{:status => 6})
        else
          @orders = @orders.where(:status => @status) 
        end
      end
      @orders = @orders.page(params[:page]).per(30)
    else
      respond_to do |format|
        format.html { render :controller => "shops", :template => "shops/no_shop" }
      end
    end
  end

  def create
    @order = @shop.orders.build(params[:order])
    @cart = @shop.carts.find(@order.cart_id)

    respond_to do |format|
      format.html do
        if @order.valid? && @order.save!
          @cart.update_attributes(checked_out: true) if @cart
          @order.update_status!(@order.payment_method=='paypal' ? 6 : 1)
          redirect_to current_site.public_url + "/shop/successful_purchase?order_id=#{@order._id}"
        else
          @message = @order.errors.full_messages
          flash[:alert] = @order.errors.full_messages
          redirect_to current_site.public_url + "/shop/cancelled_purchase?order_id=#{@order._id}"
        end
      end
      format.json do 
        if @order.valid? && @order.save!
          @cart.update_attributes(checked_out: true) if @cart
          @order.update_status!(@order.payment_method=='paypal' ? 6 : 1)
          render :json => { :order => @order }
        else
          render :json => { :errors => @order.errors.full_messages.join(" ") }
        end
      end
    end
  end

  def update_status
    respond_to do |format|
      format.json do
        if @order = @shop.orders.find(params[:id])
          if (params[:order][:status]=='message')
            @order.send_message(params[:status_message])
          else
            @order.update_status!(params[:order][:status], params[:status_message])
          end
          render :json => @order.to_json(:methods =>[:is_discounted, :total_with_discount, :offline_payment, :online_payment, :status_in_words, :contents_with_product_names_values, :created ])
        else
          render :json => { :order => false }
        end
      end
    end
  end

  def message

  end

  def start_processing
    if params[:order]
      @order.process!(params[:order][:status_message])
    end
  end

  def ship
    if params[:order]
      @order.fulfill!(params[:order][:status_message])
    end
  end

  def fulfill
    if params[:order]
      @order.fulfill!(params[:order][:status_message])
    end
  end

  def unfulfill
    @order.unfulfill!
  end

  def reject
    @order.reject!(params[:order][:status_message])
  end

  def cancelling
    if @order.cancellation_token==params[:cancellation_token]
      if @order.is_cancellable?
        # show cancellation screen 
      elsif @order.cancelled?
        @error = true
        @message = "This order has already been cancelled."
      else
        @error = true
        @message = "Sorry, your order has already been marked as fulfilled by the seller."
      end
    else
      @error = true
      @message = "Sorry, we couldn't match your cancellation token with the given order."
    end
  end

  def cancel
    @order.cancel!(params[:order][:cancellation_message])
  end

  protected

    def set_shop
      @shop = current_site.shop if current_site
      @no_sidebar = true
    end

    def check_activation
      if current_site.deactivated_by_admin?
        redirect_to current_site.url and return
      end
    end

    def set_order
      @order = @shop.orders.find(params[:id])
    end

end