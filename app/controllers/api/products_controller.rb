# app/controllers/api/products_controller.rb
module Api
  class ProductsController < ApplicationController
    def search
      begin
        query = params[:q]
        organisation_id = params[:organisation_id]
        
        puts "API Search - Query: #{query}, Organisation ID: #{organisation_id}"
        puts "API Search - Organisation ID class: #{organisation_id.class}"
        
        # Vérifiez si l'organisation existe
        organisation = Organisation.find_by(id: organisation_id)
        puts "API Search - Organisation found: #{organisation.present?}"
        
        if ActiveRecord::Base.connection.adapter_name.downcase.include?('sqlite')
          puts "API Search - Using SQLite query"
          products = Product.where(organisation_id: organisation_id)
                           .where("lower(name) LIKE ?", "%#{query.downcase}%")
                           .limit(10)
        else
          puts "API Search - Using PostgreSQL query"
          products = Product.where(organisation_id: organisation_id)
                           .where("name ILIKE ?", "%#{query}%")
                           .limit(10)
        end
        
        puts "API Search - Found #{products.count} products"
        
        # Vérifiez le chargement des produits
        products.each do |product|
          puts "API Search - Product: #{product.id}, #{product.name}, Price: #{product.prices.last.inspect}"
        end
        
        # Récupérer le prix du produit
        product_data = products.map do |product|
          {
            id: product.id,
            name: product.name,
            price: product.prices.last || 0
          }
        end
        
        puts "API Search - Rendering JSON response"
        render json: product_data
      rescue => e
        puts "API Search - ERROR: #{e.message}"
        puts "API Search - ERROR Backtrace: #{e.backtrace.join("\n")}"
        render json: { error: e.message }, status: 500
      end
    end
    
  end
end
