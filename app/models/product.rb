class Product < ApplicationRecord
  has_many :prices, dependent: :destroy
  accepts_nested_attributes_for :prices, allow_destroy: true 
  has_many :order_items
  has_many :orders, through: :order_items
end
