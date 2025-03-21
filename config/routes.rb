# config/routes.rb
Rails.application.routes.draw do
  root "pages#home"
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # Route pour l'édition des informations utilisateur
  get 'user/edit', to: 'users#edit', as: 'edit_user'
  patch 'user', to: 'users#update'

  # Routes pour edit de orga
  resource :organisation, only: [:edit, :update]

  # Rota para a pesquisa
  get 'search', to: 'home#search', as: 'search' 
  get 'infos_user', to: 'pages#infos_user', as: 'infos_user'

  resources :products do
    patch 'update_price/:price_id', to: 'products#update_price', as: 'update_price'
  end 
  resources :clients do
    resources :orders, only: [:new, :create]
  end

  resources :orders do
    get 'new_with_client_selection', on: :collection
    post 'create_with_client_selection', on: :collection
    member do
      patch 'validate'
    end
  end
  
  resources :orders, only: [:show, :edit, :update, :destroy, :index]
  
end
