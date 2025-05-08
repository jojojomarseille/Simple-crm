require 'csv'
require 'mini_magick'
class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:new, :create]
  before_action :set_order, only: [:show, :edit, :update, :destroy, :validate, :registar_payment]
  before_action :set_organisation, only: [:new, :create, :show, :edit, :index, :new_with_client_selection, :create_with_client_selection]
  before_action :set_clients_and_products, only: [:new_with_client_selection, :create_with_client_selection]

  def new
    @order = @client.orders.new
    @order.order_items.build
  end

  def show
    @order = Order.find(params[:id])
    puts "order: #{@order}"
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Prawn::Document.new
        logo_path = @organisation.logo.path
        image = MiniMagick::Image.open(logo_path)
        logo_converted_path = logo_path.sub(/\.avif$/, '.png')
        image.format('png')
        image.write(logo_converted_path)
       

        if File.exist?(logo_path)
          pdf.image logo_converted_path, width: 100, height: 100, position: :left
        else
          Rails.logger.error("Logo file not found at path: #{logo_converted_path}")
        end

        pdf.text "Facture n° #{@order.id_by_org}", size: 18, style: :bold

        pdf.move_down 10
        pdf.text "#{@organisation.business_name}", size: 12
        pdf.text "#{@organisation.address}", size: 12
        pdf.text "#{@organisation.address_line_2}" unless @organisation.address_line_2.blank?
        pdf.text "#{@organisation.postal_code} #{@organisation.city}", size: 12
        pdf.text "#{@organisation.country}", size: 12

        pdf.move_down 10
        pdf.bounding_box([pdf.bounds.right - 200, pdf.cursor], width: 200) do
          pdf.text "Client:", size: 12, style: :bold
          pdf.text "#{@order.client.name}", size: 12
          pdf.text "#{@order.client.address}", size: 12
          pdf.text "#{@order.client.postal_code} #{@order.client.city}", size: 12
          pdf.text "#{@order.client.country}", size: 12
        end

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

    @products_last_prices = Product.includes(:prices)
                                   .map do |product|
                                     last_price = product.prices.order(created_at: :desc).first
                                     [product.id, last_price&.amount]
                                   end
                                   .to_h

  end

  def edit
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to orders_path, notice: 'La commande a été supprimée avec succès.'
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
      respond_to do |format|
        format.html { redirect_to orders_path, notice: "Commande créée avec succès." }
        format.turbo_stream { redirect_to orders_path }
        format.json { render :show, status: :created, location: @order }
      end
    else
      render :new
    end
  end

  
  def create_with_client_selection
    # Filtrer les order_items vides
    if params[:order] && params[:order][:order_items_attributes]
      params[:order][:order_items_attributes].each do |key, item|
        if item[:product_id].blank?
          params[:order][:order_items_attributes].delete(key)
        end
      end
    end
    @order = Order.new(order_params)
    @order.user_id = current_user.id
    @order.organisation_id = current_user.organisation_id

    if params[:commit] == "validate"
      @order.status = "validé"
    else
      @order.status = "brouillon"
    end

    if @order.save
      respond_to do |format|
        format.html { redirect_to orders_path, notice: "Commande créée avec succès." }
        format.turbo_stream { redirect_to orders_path }
        format.json { render :show, status: :created, location: @order }
      end
    else
      render :new_with_client_selection
    end
  end
  
  def index
    sort_column = params[:sort] || 'id_by_org'
    sort_direction = params[:direction] || 'asc'
    @per_page = params[:per_page] || 20

    valid_order_columns = ['date', 'total_price_ht', 'id_by_org', 'client_id', 'status', 'payment_status', 'payment_terms', 'payment_due_date']

    if valid_order_columns.include?(sort_column) && %w[asc desc].include?(sort_direction)
      @orders = Order.where(organisation_id: @organisation.id)
                     .order("#{sort_column} #{sort_direction}")
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
    params.require(:order).permit(
      :date, 
      :client_id, 
      :payment_terms,
      :status, 
      order_items_attributes: [:id, :product_id, :quantity, :price, :_destroy]
    )
  end

end