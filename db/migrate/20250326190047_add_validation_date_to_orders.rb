class AddValidationDateToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :validation_date, :datetime
  end
end
