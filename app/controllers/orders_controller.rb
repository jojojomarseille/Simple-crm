require 'csv'
class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:new, :create]
  before_action :set_order, only: [:show, :edit, :update, :destroy, :validate, :registar_payment]
  before_action :set_organisation, only: [:new, :create, :edit, :index, :new_with_client_selection, :create_with_client_selection]
  before_action :set_clients_and_products, only: [:new_with_client_selection, :create_with_client_selection]

  def new
    @order = @client.orders.new
    @order.order_items.build
  end

  def show
    @order = Order.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        pdf.text "Facture pour la commande n° #{@order.id_by_org}", size: 18, style: :bold

        # Ajoutez ici le reste du code pour générer le PDF
        pdf.move_down 20
        pdf.text "Date de la commande: #{@order.created_at.strftime('%d/%m/%Y')}"
        pdf.text "Client: #{@order.client.name}"

        # Ajouter une table pour les articles de la commande
        pdf.move_down 20
        data = [["Article", "Quantité", "Prix Unitaire", "Total"]]
        @order.order_items.each do |item|
          data << [item.product.name, item.quantity, item.price, item.quantity*item.price ]
        end

        pdf.table(data, header: true, width: 500)

        # Ajouter le total de la commande
        pdf.move_down 20
        pdf.text "Total de la commande: #{@order.total_price_ht} €", size: 16, style: :bold

        send_data pdf.render, filename: "facture_#{@order.id_by_org}.pdf", type: "application/pdf"
      end
    end
  end

  def new_with_client_selection
    @order = Order.new
    @order.order_items.build
  end

  def edit
  end

  def registar_payment
    if @order.update(payment_status: "Payé")
      redirect_to orders_path, notice: 'Payment enregistré avec succès.'
    else
      redirect_to orders_path, alert: 'Erreur lors de la mise a jour du statut de paiement de la commande.'
    end
  end

  def validate
    if @order.update(status: "validé")
      redirect_to orders_path, notice: 'Commande validée avec succès.'
    else
      redirect_to orders_path, alert: 'Erreur lors de la validation de la commande.'
    end
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: 'Order was successfully updated.'
    else
      render :edit
    end
  end

  def create
    @order = @client.orders.build(order_params)
    @order.organisation = current_user.organisation
    @order.user_id = current_user.id

    if params[:commit] == "validate"
      @order.status = "validé"
    else
      @order.status = "brouillon"
    end

    if @order.save
      redirect_to @order, notice: 'Order was successfully created.'
    else
      render :new
    end
  end

  
  def create_with_client_selection
    @order = Order.new(order_params)
    @order.user_id = current_user.id
    @order.organisation_id = current_user.organisation_id

    if params[:commit] == "validate"
      @order.status = "validé"
    else
      @order.status = "brouillon"
    end

    puts "Order: #{@order.inspect}"
    if @order.save
      redirect_to order_path(@order), notice: 'La commande a été créée avec succès.'
    else
      render :new_with_client_selection
    end
  end
  
  def index
    order_sort = params[:order_sort] || 'name'  
    direction = params[:direction] || 'asc' 
    @per_page = params[:per_page] || 10

    valid_order_columns = ['date', 'total_price_ht', 'id_by_org', 'client_id', 'status', 'payment_status']

    if valid_order_columns.include?(order_sort) && %w[asc desc].include?(direction)
      @orders = Order.where(organisation_id: @organisation.id)
                     .order("#{order_sort} #{direction}")
                     .page(params[:page]).per(@per_page)
    else
      @orders = Order.where(organisation_id: @organisation.id)
                     .page(params[:page]).per(@per_page)
    end

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        pdf.text "Liste des Ventes", size: 30, style: :bold
        pdf.move_down 20
  
        # cette partie genere le pdf
        data = [["ID", "Date", "Client", "Mail client", "Prix HT"]] +
               @orders.map do |order|
                 [order.id, order.date.strftime("%d %b %Y"), order.client ? order.client.name : "Client inconnu", order.client ? order.client.mail : "Inconnu", order.total_price_ht]
               end
        puts "data: #{data.inspect}"
  
        pdf.table(data, header: true, row_colors: ["F0F0F0", "FFFFFF"], width: pdf.bounds.width) do
          row(0).font_style = :bold
          columns(0..3).align = :center
          self.row_colors = ["DDDDDD", "FFFFFF"]
          self.header = true
        end
        send_data pdf.render, filename: "Ventes.pdf", type: "application/pdf"
      end
      #cette partie fait le csv
      format.csv do
        headers = ["ID", "Date", "Client", "Mail client", "Prix HT"]
        csv_data = CSV.generate(headers: true) do |csv|
          csv << headers
          @orders.each do |order|
            csv << [order.id, order.date, order.client.name, order.client.mail, order.total_price_ht]
          end
        end
        send_data csv_data, filename: "Ventes.csv", type: "text/csv"
      end
    end

  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def set_client
    @client = Client.find(params[:client_id])
  end

  def set_clients_and_products
    @clients = Client.where(organisation_id: current_user.organisation_id)
    @products = Product.where(organisation_id: current_user.organisation_id)
  end

  def set_organisation
    @organisation = current_user.organisation
  end

  def order_params
    params.require(:order).permit(:date, :client_id, :payment_terms, order_items_attributes: [:product_id, :quantity, :price, :_destroy])
  end

end