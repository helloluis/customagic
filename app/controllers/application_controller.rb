class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user
    @current_user
  end

  def set_current_user(user_id)
    session[:user_id] = user_id
    @current_user = @user = User.find(user_id)
  end

  def logged_in?
    !current_user.blank?
  end

  def current_shop
    @current_shop
  end

end
