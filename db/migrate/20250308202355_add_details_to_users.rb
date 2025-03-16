class AddDetailsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :phone, :string, null: true
    add_column :users, :birthdate, :date, null: true
  end
end
