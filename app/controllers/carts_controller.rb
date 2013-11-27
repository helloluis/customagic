class CartsController

  def add
    render :action => :show
  end

  def remove
    render :action => :show
  end

  protected

    def set_cart
      @cart
    end

end