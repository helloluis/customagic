class Admin::BaseController < ApplicationController

  before_filter :authenticate_admin!
  before_filter :set_partner
  before_filter :partner_specifics_counts
  layout 'admin'

  include PartnersHelper

  def set_partner
  	@current_partner_name ||= (current_admin.partner||"infinitely")
    @current_partner = @partner_hash = App.partners.find{|p|p.short==@current_partner_name}
    logger.info "!! #{@current_partner.inspect} !!"
  end

  def is_infinitely_admin?
    current_admin.infinitely_administrator?  || current_admin.email == 'dev@infinite.ly'
  end

  def authorize_infinitely_admin!
    unless is_infinitely_admin?
      redirect_to root_path
    end
  end

  def authorize_account_admin!
    unless is_infinitely_admin? or current_admin.partner == @current_account.partner
      redirect_to accounts_path, :alert => "You are not an admin of that account" and return
    end
  end
  
  def authorize_site_admin!
    # logger.info "!!#{current_admin.partner} #{@current_site.partner}"
    unless is_infinitely_admin? or current_admin.partner==@current_site.partner
      redirect_to sites_path, :alert => "You are not an admin of that site" and return
    end
  end

  def authorize_user_admin!
    unless is_infinitely_admin? or current_admin.partner == @current_user.account.partner
      redirect_to users_path, :alert => "You are not an admin of that user" and return
    end
  end

  def set_current_account
    @current_account = @account = Account.where(:name => params[:id]).first
  end

  def set_current_site
    @current_site = @site = Site.where(:subdomain => params[:id]).first
  end

  def set_current_user
    @current_user = @user = User.find(params[:id])
  end

  def partner_specifics_counts
    unless is_infinitely_admin?
      account_ids ||= Account.only(:_id).where(partner: @current_partner_name).map(&:_id)
      @partner_accounts_count ||= account_ids.count
      @partner_sites_count ||= Site.where(:account_id.in => account_ids).count
      @partner_users_count ||= Account.where(:creator_id.ne => nil, partner: @current_partner_name).count
      # session[:partner_accounts_count] ||= account_ids.count
      # session[:partner_sites_count] ||= Site.where(:account_id.in => account_ids).count
      # session[:partner_users_count] ||= Account.where(:creator_id.ne => nil, partner: @current_partner_name).count
    end
  end

end
