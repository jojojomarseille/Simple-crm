class ApplicationController < ActionController::Base
  before_action :authenticate_user!, only: [:infos_user]
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
  end
      