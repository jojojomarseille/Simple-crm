Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'home', to: 'pages#home', as: 'home' 
  # Defines the root path route ("/")
  resources :clients
  root "pages#home"
end
