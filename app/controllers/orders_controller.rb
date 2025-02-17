class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:new, :create]
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def new
    # @order = current_user.orders.build
    # @order.order_items.build
    @order = @client.orders.new
    @order.order_items.build
  end

  def edit
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: 'Order was successfully updated.'
    else
      render :edit
    end
  end

  def create
    # @order = current_user.orders.build(order_params)
    # @order.client = Client.find(params[:client_id])
    @order = @client.orders.build(order_params)
    @order.user = current_user

    if @order.save
      redirect_to @order, notice: 'Order was successfully created.'
    else
      render :new
    end
  end
  
  def index
    @orders = Order.includes(:client, :user).all
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def set_client
    @client = Client.find(params[:client_id])
  end

  def order_params
    params.require(:order).permit(:date, order_items_attributes: [:product_id, :quantity, :price, :_destroy])
  end
end
