# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  # Rota para a pesquisa
  get 'search', to: 'home#index', as: 'search' 

  resources :products do
    patch 'update_price/:price_id', to: 'products#update_price', as: 'update_price'
  end 
  resources :clients
  
  root "pages#home"
end
