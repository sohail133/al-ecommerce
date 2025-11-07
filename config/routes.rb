Rails.application.routes.draw do
  root "pages#home"
  
  resources :products, only: [:index, :show]
  resources :categories, only: [:show]
  
  get "cart", to: "cart#show", as: :cart
  post "cart/add", to: "cart#add", as: :add_to_cart
  delete "cart/remove/:variant_id", to: "cart#remove", as: :remove_from_cart
  delete "cart/clear", to: "cart#clear", as: :clear_cart
  patch "cart/update_quantity/:id", to: "cart#update_quantity", as: :cart_update_quantity
  patch "cart/update_variant/:id", to: "cart#update_variant", as: :cart_update_variant
  
  get "checkout", to: "checkout#show", as: :checkout
  post "checkout", to: "checkout#create"
  get "orders/:id/confirmation", to: "orders#confirmation", as: :order_confirmation
  
  resources :addresses, only: [:new, :create]
  
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :admin do
    root "dashboard#index"
    resources :dashboard, only: [:index]
    
    resources :users, only: [:index, :show, :edit, :update] do
      member do
        patch :activate
        patch :deactivate
      end
    end
    
    resources :addresses, only: [:index, :show]
    resources :categories
    resources :subcategories
    resources :products do
      member do
        delete :delete_image
      end
    end
    resources :product_variants
    resources :inventories, only: [:edit, :create, :update]
    resources :payment_methods
    resources :orders, only: [:index, :show, :edit, :update]
  end
end
