class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, default: "", null: false
      t.string :encrypted_password, default: "", null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.string :firstname
      t.string :lastname
      t.string :phone
      t.date :birthdate
      t.string :status
      t.json :dashboard_blocks_order
      t.references :organisation, type: :uuid, foreign_key: true

      t.timestamps
      
      t.index :email, unique: true
      t.index :reset_password_token, unique: true
    end
  end
end
