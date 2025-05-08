class AddBaseCompanyRefToOrganisations < ActiveRecord::Migration[7.0]
  def change
    add_reference :organisations, :base_company, null: true, foreign_key: true
  end
end
