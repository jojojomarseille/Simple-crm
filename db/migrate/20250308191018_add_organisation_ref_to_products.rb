class AddOrganisationRefToProducts < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :organisation, null: true, foreign_key: true
  end
end
