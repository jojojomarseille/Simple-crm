require 'csv'
class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:show, :edit, :update, :destroy, :update_price]
  before_action :set_price, only: [:update_price]
  before_action :set_organisation, only: [:new, :create, :index]

  def index
    sort_column = params[:sort] || 'id'
    sort_direction = params[:direction] || 'asc'
    @per_page = params[:per_page] || 10
  
    valid_order_columns = ['id', 'name', 'description', 'price']
  
    @products = Product.where(organisation_id: current_user.organisation.id)
  
    if valid_order_columns.include?(sort_column) && %w[asc desc].include?(sort_direction)
      if sort_column == 'price'
        # Tri spécial avec jointure pour la colonne prix
        @products = @products.joins(:prices)
                             .select('products.*, prices.amount AS price_amount')
                             .order("price_amount #{sort_direction}")
      else
        # Tri standard pour les autres colonnes
        @products = @products.order("#{sort_column} #{sort_direction}")
      end
    end
  
    @products = @products.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        pdf.text "Liste des Produits", size: 30, style: :bold
        pdf.move_down 20
  
        # Construction d'un tableau avec les produits
        data = [["ID", "Nom", "Description", "Prix"]] +
               @products.map do |product|
                 [product.id, product.name, product.description, product.prices.last.amount]
               end
  
        pdf.table(data, header: true, row_colors: ["F0F0F0", "FFFFFF"], width: pdf.bounds.width) do
          row(0).font_style = :bold
          columns(0..3).align = :center
          self.row_colors = ["DDDDDD", "FFFFFF"]
          self.header = true
        end
        send_data pdf.render, filename: "produits.pdf", type: "application/pdf"
      end
      format.csv do
        headers = ["ID", "Nom", "Description", "Prix"]
        csv_data = CSV.generate(headers: true) do |csv|
          csv << headers
          @products.each do |product|
            csv << [product.id, product.name, product.description, product.prices.last.amount]
          end
        end
        send_data csv_data, filename: "produits.csv", type: "text/csv"
      end
    end

  end

  # 👁️ Mostrar detalhes de um produto
  def show
    @prices = @product.prices
  end

  # ➕ Formulário para novo produto
  def new
    @product = Product.new
    @product.prices.build
  end

  # 📝 Formulário para editar produto
  def edit
  end

  # Atualizar preço diretamente da página de produto
  def update_price
    if @price.update(price_params)
      redirect_to @product, notice: 'Preço atualizado com sucesso.'
    else
      redirect_to @product, alert: 'Erro ao atualizar preço.'
    end
  end

  # 💾 Salvar novo produto
  def create
    @product = Product.new(product_params)
    @product.organisation = @organisation
    puts "organisation id: #{@organisation.id}"
    if @product.save
      redirect_to @product, notice: 'Produto criado com sucesso.'
    else
      puts "le create n'a pas fonctionné"
      puts "le produits que j'ai soumis: #{@product.inspect}"
      render :new
    end
  end

  # 🔄 Atualizar produto existente
  def update
    if @product.update(product_params)
      # if params[:product][:prices_attributes]["0"][:amount].present?
      #   @product.prices.create(amount: params[:product][:prices_attributes]["0"][:amount], currency: "EUR")
      # end
      redirect_to @product, notice: 'Produto atualizado com sucesso.'
    else
      render :edit
    end
  end

  # 🗑️ Deletar produto
  def destroy
    @product.destroy
    redirect_to products_url, notice: 'Produto excluído com sucesso.'
  end

  private

  # 🔑 Buscar produto por ID
  def set_product
    @product = Product.find(params[:id])
    @price = @product.prices.last
  end

  def set_organisation
    @organisation = current_user.organisation
  end

  # 📦 Parâmetros permitidos para o produto
  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, :product_image, prices_attributes: [:id, :amount, :currency, :_destroy])
  end

  # Parâmetros permitidos para o preço
  def price_params
    params.require(:price).permit(:amount, :currency)
  end

  # 🔑 Buscar o preço específico de um produto
  def set_price
    @price = @product.prices.find(params[:price_id])
  end
end
