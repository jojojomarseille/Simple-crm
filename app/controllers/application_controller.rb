class ApplicationController < ActionController::Base
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
      