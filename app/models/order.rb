class Order < ApplicationRecord
  belongs_to :client
  belongs_to :user
  has_many :order_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :order_items
  accepts_nested_attributes_for :order_items, allow_destroy: true 


  # before_save :calculate_total_price
   
  private

  def calculate_total_price
    self.price = order_items.sum { |item| item.quantity * item.price }
  end

end
