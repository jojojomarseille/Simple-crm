class AddIdByOrgToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :id_by_org, :integer
  end
end
