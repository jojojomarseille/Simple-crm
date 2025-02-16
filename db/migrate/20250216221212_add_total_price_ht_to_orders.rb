class AddTotalPriceHtToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :total_price_ht, :decimal
  end
end
