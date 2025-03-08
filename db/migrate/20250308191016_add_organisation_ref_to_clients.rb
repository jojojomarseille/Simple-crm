class AddOrganisationRefToClients < ActiveRecord::Migration[7.0]
  def change
    add_reference :clients, :organisation, null: true, foreign_key: true
  end
end
