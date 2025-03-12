class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:show, :edit, :update, :destroy, :update_price]
  before_action :set_price, only: [:update_price]
  before_action :set_organisation, only: [:new, :create, :index]

  def index
    order = params[:order] || 'name'  
    direction = params[:direction] || 'asc' 

    valid_order_attributes = %w[id name]

    if order == 'price'
      @products = Product.joins(:prices) 
                        .where(organisation_id: current_user.organisation.id)
                        .select('products.*, prices.amount AS price_amount') 
                        .order("price_amount #{direction}")
    elsif valid_order_attributes.include?(order) && %w[asc desc].include?(direction)
      @products = Product.where(organisation_id: current_user.organisation.id).order("#{order} #{direction}")
    else
      @products = Product.where(organisation_id: current_user.organisation.id)
    end
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
