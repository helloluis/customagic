class Admin::UsersController < Admin::BaseController

  before_filter :set_current_user, except: [:index, :new, :create]
  before_filter :authorize_user_admin!, only: [:show, :edit, :update, :destroy]
  before_filter :authorize_infinitely_admin!, only: [:new, :create]
  before_filter :set_title, only: [:show, :edit]

  #add_crumb("Users") { |instance| instance.send :users_path }

  respond_to :js, :html, :json

  def index
    @page_title = "Users"
    @only = 'users'
    if is_infinitely_admin?
      
      @users = User.includes(:account, :sites).page(params[:page]).per(params[:per] || 50)

      sort_by = params[:sort_by]
      sort_dir = params[:sort_dir]
      
      if params[:sort_by]
        @users = @users.order_by(sort_by.to_sym, sort_dir.to_sym)
      else
        @users = @users.order_by([:created_at, :desc])
      end

    else
      if params[:sort_by]
        all_users ||= User.all.order_by(sort_by.to_sym, sort_dir.to_sym)
      else
        all_users ||= User.all.order_by([:created_at, :desc])
      end

      @users = []
      all_users.each do |user|
        if !user.account.nil? && user.account.partner == @current_partner_name
          @users << user
        end
      end

      @users = Kaminari.paginate_array(@users).page(params[:page]).per(params[:per] || 50)
     
    end

    respond_with @users
  end

  def new
    @user = User.new(params[:user], params[:account_id])
    respond_with @user
  end

  def create
    @user = User.new params[:user]
    # @user.create_default_account! if @user.valid? && @user.save

    if params[:account_id] != ""
      begin
        @account = Account.find(params[:account_id])
      rescue Moped::BSON::InvalidObjectId
        flash[:alert] = t(:account_does_not_exist)
      end
      
      if @account && @account.creator.nil?
        @user.skip_confirmation!
        if @user.valid? && @user.save
          @account.update_attributes(creator: @user, claimed_by_guest: false, created_by_guest: nil)
          @account.permissions.create(user: @user, admin: true)
          flash[:notice] = "Email changed successfully" #t(:user_created_linked_to_account)
          redirect_to users_path
        else
          render 'new', :params => { :account_id => params[:account_id] }
        end
      else
        flash[:alert] = t(:account_does_not_exist)
        render 'new', :params => { :account_id => params[:account_id] }
      end

    else
      @user.skip_confirmation!
      if @user.valid? && @user.save
        flash[:notice] = t(:user_created)
        redirect_to users_path
      else
        render 'new'
      end
    end

  end

  def show
    @only = 'users'
    add_crumb @user.email, @users
    respond_with @user
  end

  def edit
    @only = 'users'
    add_crumb @user.email, @users
    respond_with @user
  end

  def update
    @user.skip_confirmation!
    if @user.update_attributes params[:user]
      @user.reload
      flash[:notice] = t(:user_update_confirmation)
    else
      flash[:alert] = t(:error_encountered)
    end
    respond_with @user
  end

  def destroy
    @user.destroy
    respond_with @user
  end

  protected

  def set_title
    @page_title = "Users - #{User.find(params[:id]).email.to_s}"
  end

end