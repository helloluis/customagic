class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_shop
    @current_shop
  end

  def authenticate_user!
    logger.info "!! SIGNED IN? #{user_signed_in?} #{current_user && current_user.shop} !!"
    unless user_signed_in? && current_user.shop #&& current_user.account.sites.any?
      respond_to do |format|
        format.html { redirect_to root_path, :alert => "You need to log in to do that." and return }
        format.json { render :json => { :errors => "You need to log in to do that." }, :status => 401 }
      end
    end
  end
  alias :require_user :authenticate_user!

  def authorize_account_user!
    unless current_user and current_user.is_owner?(current_shop)
      respond_to do |format|
        format.html { redirect_to "/#{current_shop.slug}", "You are not the owner of that shop. You may need to logout and sign in again." and return }
        format.json { render :json => { :errors => "You are not the owner of that shop. You may need to logout and sign in again." }, :status => 401 }
      end
    end
  end
  alias :require_account_user :authorize_account_user!

  def mobile_browser?
    return true if params[:mobile_site]
    @app_mobile_devices ||= Regexp.union(App.mobile_devices)
    request.user_agent && request.user_agent.downcase[@app_mobile_devices]
  end
  helper_method :mobile_browser?
end
