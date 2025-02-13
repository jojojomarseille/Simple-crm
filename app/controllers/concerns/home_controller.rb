# app/controllers/home_controller.rb
class HomeController < ApplicationController
    # def search
      # Realizando a pesquisa
      # if params[:query].present?
      #  @clients = Client.where('name LIKE ?', "%#{params[:query]}%")
      #  puts "clients:  #{@clients.last.name}, mail: #{@clients.last.mail}" 
      #  @products = Product.where('name LIKE ?', "%#{params[:query]}%")
     # else
    #    @clients = Client.all
    #    @products = Product.all
    #  end
    #  respond_to do |format|
    #    format.turbo_stream do
    #      render turbo_stream: turbo_stream.replace("results", partial: "searches/results", locals: { results: @results }) 
    #  end
    # end 
    def search
      if params[:query].present?
        @clients = Client.where('name LIKE ?', "%#{params[:query]}%")
        @products = Product.where('name LIKE ?', "%#{params[:query]}%")
        puts "clients:  #{@clients.last.name}, mail: #{@clients.last.mail}" 
      else
        @clients = []
        @products = []
      end
  
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "search_results", 
            partial: "home/search_results", 
            locals: { clients: @clients, products: @products }
          )
        end
        format.html # Pour permettre le support des requêtes non-Ajax
      end
    end 
end
  