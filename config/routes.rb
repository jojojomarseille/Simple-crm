Rails.application.routes.draw do
  root "pages#home"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'home', to: 'pages#home', as: 'home' 
  # Defines the root path route ("/")
  resources :products do
    patch 'update_price/:price_id', to: 'products#update_price', as: 'update_price'
  end 
  resources :clients do
    resources :orders, only: [:new, :create]
  end
  resources :orders, only: [:show, :edit, :update, :destroy, :index]
  
end
