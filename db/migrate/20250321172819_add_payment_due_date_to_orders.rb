class AddPaymentDueDateToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :payment_due_date, :date
  end
end
