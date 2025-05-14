class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders, id: :uuid do |t|
      t.datetime :date
      t.references :client, type: :uuid, null: false, foreign_key: true
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.decimal :total_price_ht
      t.references :organisation, type: :uuid, foreign_key: true
      t.string :status, default: "brouillon"
      t.integer :payment_terms
      t.date :payment_due_date
      t.integer :id_by_org
      t.string :payment_status, default: "En attente"
      t.datetime :validation_date
      t.datetime :payment_date

      t.timestamps
    end
  end
end
