# app/controllers/home_controller.rb
class HomeController < ApplicationController
    def index
      # Realizando a pesquisa
      if params[:query].present?
        @clients = Client.where('name LIKE ?', "%#{params[:query]}%")
        @products = Product.where('name LIKE ?', "%#{params[:query]}%")
      else
        @clients = Client.all
        @products = Product.all
      end
    end
  end
  