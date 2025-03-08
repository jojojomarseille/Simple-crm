class Product < ApplicationRecord
  belongs_to :organisation
  has_many :prices, dependent: :destroy 
  accepts_nested_attributes_for :prices, allow_destroy: true
  has_many :order_items
  has_many :orders, through: :order_items

  mount_uploader :product_image, ImageProductUploader 
end
