class Product < ApplicationRecord
    has_many :prices, dependent: :destroy
    accepts_nested_attributes_for :prices, allow_destroy: true 
    mount_uploader :product_image, ImageProductUploader 
end
