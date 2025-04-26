# config/routes.rb
Rails.application.routes.draw do
  root "pages#home"
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  devise_scope :user do
    # Routes pour les formulaires initiaux (GET)
    get 'users/registrations/step1', to: 'users/registrations#new', as: 'step1_users_registrations'
    get 'users/registrations/step2', to: 'users/registrations#step2_get', as: 'step2_users_registrations_get'
    get 'users/registrations/step3', to: 'users/registrations#step3_get', as: 'step3_users_registrations_get'
    get 'users/registrations/step4', to: 'users/registrations#step4_get', as: 'step4_users_registrations_get'
    
    # Routes pour soumettre les formulaires (POST)
    post 'users/registrations/step2', to: 'users/registrations#step2', as: 'step2_users_registrations'
    post 'users/registrations/step3', to: 'users/registrations#step3', as: 'step3_users_registrations'
    post 'users/registrations/step4', to: 'users/registrations#step4', as: 'step4_users_registrations'
    
    get 'users/registrations/autocomplete', to: 'users/registrations#autocomplete', as: :autocomplete_base_companies
  end

  get 'users_index', to: 'users#index', as: 'users_index'

  get 'users/new_collaborator', to: 'users#new_collaborator', as: 'new_collaborator'
  post 'users/create_collaborator', to: 'users#create_collaborator', as: 'create_collaborator'

  resources :users, only: [:show, :edit, :update, :destroy]

  # Routes pour edit de orga
  resource :organisation, only: [:edit, :update]

  # Rota para a pesquisa
  get 'search', to: 'home#search', as: 'search' 
  get 'infos_user', to: 'pages#infos_user', as: 'infos_user'
  get 'connected_home', to: 'pages#connected_home', as: 'connected_home'
  post 'pages/save_dashboard_order', to: 'pages#save_dashboard_order'

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
      patch 'registar_payment'
    end
  end
  
  resources :orders, only: [:show, :edit, :update, :destroy, :index]

  namespace :api do
    resources :base_companies, only: [] do
      collection do
        get :search
      end
    end
    resources :products, only: [] do
      collection do
        get :search
      end
    end
  end
  
end
