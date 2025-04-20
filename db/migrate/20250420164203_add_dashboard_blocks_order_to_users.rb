class AddDashboardBlocksOrderToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :dashboard_blocks_order, :json
  end
end
