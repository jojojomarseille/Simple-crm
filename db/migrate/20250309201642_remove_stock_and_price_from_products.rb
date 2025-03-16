class RemoveStockAndPriceFromProducts < ActiveRecord::Migration[7.0]
  def change
    remove_column :products, :stock, :integer
    remove_column :products, :price, :decimal
  end
end
