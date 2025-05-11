class ApplicationController < ActionController::Base
  before_action :authenticate_user!, only: [:infos_user]
  skip_before_action :authenticate_user!, only: [:maintenance, :countdown]
  layout false, only: [:maintenance, :countdown]

    def index
      # Se já houver uma query, as variáveis @clients e @products vão buscar os resultados
      if params[:query].present?
        @clients = Client.where('name LIKE ?', "%#{params[:query]}%")
        @products = Product.where('name LIKE ?', "%#{params[:query]}%")
      else
        @clients = Client.all
        @products = Product.all
      end
    end

    def after_sign_in_path_for(resource)
      connected_home_path
    end

    def maintenance
    end
    
    def countdown
      @countdown_value = AppConfig.countdown_value
    end
end
      