class Admin::DashboardController < Admin::BaseController

  layout false

  respond_to :js, :html, :json

  def index

    @date_today = DateTime.now.in_time_zone(current_partner.time_zone || "GMT")

    unless is_infinitely_admin?
      
      @partner_accounts ||= Account.where(:partner => @current_partner_name).map(&:_id)
      @sites = Site.where(:partner => @current_partner_name)

      @latest_sites ||= @sites.desc(:created_at).limit(50)
      @unclaimed_accounts ||= Account.where(:partner => @current_partner_name, :claimed_by_guest => false, :creator_id => '').desc(:created_at).limit(50)
      
      @total_accounts ||= @sites.count
      @total_unclaimed_accounts ||= @unclaimed_accounts.count
        
      @new_accounts_today = Site.where(:partner => current_partner.short, :created_at.gt => @date_today.at_beginning_of_day.to_time).count
      @new_accounts_week  = Site.where(:partner => current_partner.short, :created_at.gt => @date_today.at_beginning_of_week.to_time).count
      @new_accounts_month = Site.where(:partner => current_partner.short, :created_at.gt => @date_today.at_beginning_of_month.to_time).count
      @new_accounts_last_month = Site.where(:partner => current_partner.short, :created_at.gt => @date_today.at_beginning_of_month.to_time-30.days, :created_at.lt => @date_today.at_beginning_of_month.to_time).count
      @new_accounts_this_year  = Site.where(:partner => current_partner.short, :created_at.gt => Date.parse("#{@date_today.year}/1/1")).count

      @all_accounts = {}
      app_plans.each do |k,plan|
        count = Site.where(partner: current_partner.short, plan_type: plan.type).count
        @all_accounts[plan.type] = { name: plan.title + " (#{plan.frequency}ly)", count: count }
      end

    else

      @latest_sites ||= Site.desc(:created_at).limit(50)
      @unclaimed_accounts ||= Account.where(:claimed_by_guest => false, :creator_id => '').desc(:created_at).limit(50)
      
      @total_accounts ||= Site.count
      @new_accounts_today = Site.where(:created_at.gt => @date_today.at_beginning_of_day.to_time).count
      @new_accounts_week  = Site.where(:created_at.gt => @date_today.at_beginning_of_week.to_time).count
      @new_accounts_month = Site.where(:created_at.gt => @date_today.at_beginning_of_month.to_time).count
      @new_accounts_last_month = Site.where(:created_at.gt => @date_today.at_beginning_of_month.to_time-30.days, :created_at.lt => @date_today.at_beginning_of_month.to_time).count
      @new_accounts_this_year  = Site.where(:created_at.gt => Date.parse("#{Date.today.year}/1/1")).count
      @all_accounts = {}
      App.plans.each do |k,plan|
        count = Site.where(plan_type: plan.type).count
        @all_accounts[plan.type] = { name: plan.title + " (#{plan.frequency}ly)", count: count }
      end

      @num_orders = Order.not_in(status:[4,5]).count
      @today_orders = Order.where(:created_at.gt => @date_today.to_time).count
      @week_orders  = Order.where(:created_at.gt => @date_today.at_beginning_of_week.to_time).count
      @total_orders = Order.not_in(status:[4,5]).only(:total).map(&:total).compact.sum
      @today_order_totals = Order.where(:created_at.gt => @date_today.to_time).only(:total).map(&:total).compact.sum
      @week_order_totals  = Order.where(:created_at.gt => @date_today.at_beginning_of_week.to_time).only(:total).map(&:total).compact.sum
    end
    
    respond_with @latest_sites, @unclaimed_accounts

  end

end