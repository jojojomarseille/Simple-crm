require 'csv'
class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :set_organisation, only: [:new, :create, :index]

  # 📋 Listar todos os clientes
  def index
    order = params[:order] || 'name' 
    direction = params[:direction] || 'asc' 
    @per_page = params[:per_page] || 10

    # Verifica se a direção é 'desc' para reverter a ordem
    if %w[name client_type].include?(order) && %w[asc desc].include?(direction)
      @clients = Client.where(organisation_id: @organisation.id)
                       .order("#{order} #{direction}")
                       .page(params[:page]).per(@per_page)
    else
      @clients = Client.where(organisation_id: @organisation.id)
                       .page(params[:page]).per(@per_page)
    end

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        pdf.text "Liste des Clients", size: 30, style: :bold
        pdf.move_down 20
  
        # Construction d'un tableau avec les clients
        data = [["ID", "Nom", "Typo", "Mail", "Phone", "Adresse", "City", "Country", "CP"]] +
               @clients.map do |client|
                 [client.id, client.name, client.client_type, client.mail, client.phone, client.address, client.city, client.country, client.postal_code]
               end
  
        pdf.table(data, header: true, row_colors: ["F0F0F0", "FFFFFF"], width: pdf.bounds.width) do
          row(0).font_style = :bold
          columns(0..3).align = :center
          self.row_colors = ["DDDDDD", "FFFFFF"]
          self.header = true
        end
        send_data pdf.render, filename: "clients.pdf", type: "application/pdf"
      end
      format.csv do
        headers = ["ID", "Nom", "Typo", "Mail", "Phone", "Adresse", "City", "Country", "CP"]
        csv_data = CSV.generate(headers: true) do |csv|
          csv << headers
          @clients.each do |client|
            csv << [client.id, client.name, client.client_type, client.mail, client.phone, client.address, client.city, client.country, client.postal_code]
          end
        end
        send_data csv_data, filename: "clients.csv", type: "text/csv"
      end
    end

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
    @client.organisation = @organisation
    puts "organisation id: #{@organisation.id}"
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

  def set_organisation
    @organisation = current_user.organisation
  end

  # 📦 Parâmetros permitidos
  def client_params
    params.require(:client).permit(:name, :client_type, :mail, :phone, :address, :image, :city, :country, :postal_code, :latitude, :longitude)
  end
end
