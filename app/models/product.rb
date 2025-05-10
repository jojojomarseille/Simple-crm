class Product < ApplicationRecord
  belongs_to :organisation
  has_many :prices, dependent: :destroy 
  accepts_nested_attributes_for :prices, allow_destroy: true
  has_many :order_items
  has_many :orders, through: :order_items

  mount_uploader :product_image, ImageProductUploader 

  # def latest_price
  #   prices.order(created_at: :desc).first
  # end
  def latest_price
    prices.last&.amount || 0
  end

  def self.ransackable_associations(auth_object = nil)
    %w[organisation prices order_items orders]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name description created_at updated_at product_image organisation_id]
  end

end
