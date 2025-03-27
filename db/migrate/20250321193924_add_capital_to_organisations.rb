class AddCapitalToOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :capital, :string
  end
end
