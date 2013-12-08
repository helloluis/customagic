Customagic::Application.routes.draw do

  # Admin Routes
  constraints RouteConstraints::Subdomain::Admin do
    devise_for :admin, path: "", module: "admin",
      path_names: { sign_in: :login, sign_out: :logout },
      only: [:sessions, :passwords, :unlock]

    as :admin do
      get   "login"   => "admin/sessions#new",     as: :admin_login
      post  "login"   => "admin/sessions#create",  as: :admin_session
      get   "logout"  => "admin/sessions#destroy", as: :admin_logout

      resource :password, controller: "admin/passwords"
    end

    scope module: "admin" do
      resources :mastheads
      resources :shops
      resources :orders
      resources :users
      resources :products do
        get :toggle_feature
        get :toggle_visibility
        get :update_category
      end
      resources :themes
      resources :admins
    end

    match 'login_as/:user_id' => 'admin/user_sessions#create', as: :login_as
    match 'search' => 'admin/search#index'

    match "sites-validate" => "sites#validate"
    match "users-validate" => "user#validate"

    root to: "admin/dashboard#index"

  end

  resource :marketplace do
    get :featured
  end
  resources :canned_images do 
    get :memes, on: :collection
  end
  resources :shops do
    get  :successful_purchase
    get  :cancelled_purchase
    resources :assets do
      post :create_photo, on: :collection
    end
    resources :orders
    resources :customers
    resources :products do
      get  :edit_info,    on: :member
      post :update_info,  on: :member
      get  :ready,        on: :member
    end
  end

  resources :products
  
  resources :carts do
    get 'view',           on: :collection
    get 'check_out',      on: :collection
    get 'empty',          on: :collection
    get 'update_cart',    on: :collection
    get 'add_product',    on: :collection
    get 'remove_product', on: :collection
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in',  :to => 'devise/sessions#new',     :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  resources :users

  match '/orders' => "orders#create", :method => :post
  match '/shop/successful_purchase' => 'shops#successful_purchase', :method => :get
  match '/shop/cancelled_purchase'  => 'shops#cancelled_purchase',  :method => :get
  match "/payment_notifications/paypal" => "payment_notifications#paypal", :as => :paypal_payment_notifications
  # match "/:shop_id/:id" => "products#show", :method => :get
  match "/:shop_id/products/new" => "products#new", :method => :get
  match "/:shop_id/products/:id/edit" => "products#edit", :method => :get
  match "/:shop_id/products/:id/edit_info" => "products#edit_info", :method => :get
  match "/user/hearts" => "users#hearts"
  match "/user/toggle_heart/:id" => "users#toggle_heart"
  match "/:id" => "shops#show", :method => :get

  root :to => "landing#index"

end
