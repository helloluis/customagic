Customagic::Application.routes.draw do

  resource :marketplace do
    get :featured
  end
  resources :shops do
    resources :assets do
      post :create_photo, on: :collection
    end
    resources :orders
    resources :customers
    resources :products do
      get  :edit_info,    on: :member
      post :update_info,  on: :member
    end
    resources :carts do
      get 'add_product',    on: :collection
      get 'remove_product', on: :collection
    end
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in',  :to => 'devise/sessions#new',     :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  resources :users
  
  match "/:shop_id/:id" => "products#show", :method => :get
  match "/:shop_id/products/new" => "products#new", :method => :get
  match "/:shop_id/products/:id/edit" => "products#edit", :method => :get
  match "/:shop_id/products/:id/edit_info" => "products#edit_info", :method => :get

  match "/:id" => "shops#show", :method => :get

  root :to => "landing#index"

end
