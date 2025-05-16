class CreateClients < ActiveRecord::Migration[7.0]
  def change
    create_table :clients, id: :uuid do |t|
      t.string :name
      t.string :client_type
      t.string :mail
      t.string :phone
      t.string :address
      t.string :image
      t.string :city
      t.string :country
      t.string :postal_code
      t.decimal :latitude
      t.decimal :longitude
      t.references :organisation, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
