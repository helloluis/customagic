class UsersController < ApplicationController

  include ApplicationHelper

  def show

    @user = User.find_or_create_by(:fb_id => params[:id], :partner => app_partner_name)
    
    @user.write_attributes( name:        params[:name],
                            first_name:  params[:first_name],
                            last_name:   params[:last_name],
                            city:        params[:city],
                            email:       params[:email], 
                            fb_id:       params[:fb_id],
                            fb_url:      params[:fb_link], 
                            fb_username: params[:fb_username] )

    @user.save
    @user.reload

    set_current_user(@user.id)
    
    respond_to do |format|
      format.json { render :json => @user.shop.as_json(:methods => [ :slug ]), :callback => params[:callback] }
    end
  end

  def hearts
    if user_signed_in?
      respond_to do |format|
        format.json { render :json => current_user.favorite_product_ids, :callback => params[:callback] }
      end
    end
  end
  
end