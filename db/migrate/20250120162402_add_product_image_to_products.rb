class AddProductImageToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :product_image, :string
  end
end
