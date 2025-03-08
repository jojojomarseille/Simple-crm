# config/routes.rb
Rails.application.routes.draw do
  root "pages#home"
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  # Rota para a pesquisa
  get 'search', to: 'home#search', as: 'search' 
  get 'infos_user', to: 'pages#infos_user', as: 'infos_user'

  resources :products do
    patch 'update_price/:price_id', to: 'products#update_price', as: 'update_price'
  end 
  resources :clients do
    resources :orders, only: [:new, :create]
  end
  resources :orders, only: [:show, :edit, :update, :destroy, :index]
  
end
