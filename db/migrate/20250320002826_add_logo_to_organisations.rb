class AddLogoToOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_column :organisations, :logo, :string
  end
end
