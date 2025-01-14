class AddDetailsToClients < ActiveRecord::Migration[7.0]
  def change
    add_column :clients, :city, :string
    add_column :clients, :country, :string
    add_column :clients, :postal_code, :string
    add_column :clients, :latitude, :decimal
    add_column :clients, :longitude, :decimal
  end
end
