class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  # 📋 Listar todos os clientes
  def index
    @clients = Client.all
  end

  # 👁️ Mostrar detalhes de um cliente
  def show
  end

  # ➕ Formulário para novo cliente
  def new
    @client = Client.new
  end

  # 📝 Formulário para editar cliente
  def edit
  end

  # 💾 Salvar novo cliente
  def create
    @client = Client.new(client_params)
    if @client.save
      redirect_to @client, notice: 'Cliente criado com sucesso.'
    else
      render :new
    end
  end

  # 🔄 Atualizar cliente existente
  def update
    if @client.update(client_params)
      redirect_to @client, notice: 'Cliente atualizado com sucesso.'
    else
      render :edit
    end
  end

  # 🗑️ Deletar cliente
  def destroy
    @client.destroy
    redirect_to clients_url, notice: 'Cliente excluído com sucesso.'
  end

  private

  # 🔑 Buscar cliente por ID
  def set_client
    @client = Client.find(params[:id])
  end

  # 📦 Parâmetros permitidos
  def client_params
    params.require(:client).permit(:name, :client_type, :mail, :phone, :address, :image, :city, :country, :postal_code, :latitude, :longitude )
  end
end
