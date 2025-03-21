class AddPaymentTermToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :payment_terms, :string
  end
end
