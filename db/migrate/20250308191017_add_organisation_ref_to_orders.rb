class AddOrganisationRefToOrders < ActiveRecord::Migration[7.0]
  def change
    add_reference :orders, :organisation, null: true, foreign_key: true
  end
end
