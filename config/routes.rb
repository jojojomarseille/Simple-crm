# config/routes.rb
Rails.application.routes.draw do
  root "pages#home"
  devise_for :users
  # Rota para a pesquisa
  get 'search', to: 'home#search', as: 'search' 

  resources :products do
    patch 'update_price/:price_id', to: 'products#update_price', as: 'update_price'
  end 
  resources :clients do
    resources :orders, only: [:new, :create]
  end
  resources :orders, only: [:show, :edit, :update, :destroy, :index]
  
end
