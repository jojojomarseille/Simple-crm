require 'csv'
class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :set_organisation, only: [:new, :create, :index, :show]

  def index
    sort_column = params[:sort] || 'id_by_org'
    sort_direction = params[:direction] || 'asc'
    @per_page = params[:per_page] || 20

    valid_order_columns = ['id', 'name', 'client_type', 'mail', 'phone', 'address', 'city', 'country', 'postal_code']

    if valid_order_columns.include?(sort_column) && %w[asc desc].include?(sort_direction)
      @clients = Client.where(organisation_id: @organisation.id)
                       .order("#{sort_column} #{sort_direction}")
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

  def show
  end

  def new
    @client = Client.new
  end

  def edit
  end

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

  def update
    if @client.update(client_params)
      redirect_to @client, notice: 'Cliente atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_url, notice: 'Cliente excluído com sucesso.'
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def set_organisation
    @organisation = current_user.organisation
  end

  def client_params
    params.require(:client).permit(:name, :client_type, :mail, :phone, :address, :image, :city, :country, :postal_code, :latitude, :longitude)
  end
end
