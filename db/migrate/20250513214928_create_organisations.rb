class CreateOrganisations < ActiveRecord::Migration[7.0]
  def change
    create_table :organisations, id: :uuid do |t|
      t.string :status
      t.datetime :creation_date
      t.string :business_name
      t.string :address
      t.string :address_line_2
      t.string :postal_code
      t.string :city
      t.string :country
      t.string :identification_number
      t.string :vat_number
      t.string :logo
      t.string :capital
      t.references :base_company, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
