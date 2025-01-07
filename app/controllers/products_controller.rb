class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy, :update_price]
  before_action :set_price, only: [:update_price] 

  # 📋 Listar todos os produtos
  def index
    @products = Product.all
  end

  # 👁️ Mostrar detalhes de um produto
  def show
  end

  # ➕ Formulário para novo produto
  def new
    @product = Product.new
    @product.prices.build 
  end

  # 📝 Formulário para editar produto
  def edit
  end

  # Updates a price directly from the product show page
  def update_price
    if @price.update(price_params)
      redirect_to @product, notice: 'Price updated successfully.'
    else
      redirect_to @product, alert: 'Error updating price.'
    end
  end 

  # 💾 Salvar novo produto
  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to @product, notice: 'Produto criado com sucesso.'
    else
      render :new
    end
  end

  # 🔄 Atualizar produto existente
  def update
    if @product.update(product_params)
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
    # Adjust to :product_id
  end 

  # 📦 Parâmetros permitidos
  def product_params
    params.require(:product).permit(:name, :description, :price, :stock, prices_attributes: [:id, :amount, :currency, :_destroy])
  end

  def price_params
    params.require(:price).permit(:amount, :currency)
  end 

  def set_price
    @price = @product.prices.find(params[:price_id]) # Find specific price tied to the product
  end 

end
