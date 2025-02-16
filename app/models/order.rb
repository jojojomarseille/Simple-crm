class Order < ApplicationRecord
  belongs_to :client
  belongs_to :user
  has_many :order_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :order_items
  accepts_nested_attributes_for :order_items, allow_destroy: true 

  before_save :calculate_total_price_ht
   
  private

  def calculate_total_price_ht
    self.total_price_ht = order_items.sum { |item| item.price.to_f * item.quantity.to_i }
  end

end
