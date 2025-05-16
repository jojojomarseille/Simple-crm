class CreatePrices < ActiveRecord::Migration[7.0]
  def change
    create_table :prices, id: :uuid do |t|
      t.decimal :amount
      t.string :currency, default: "Euros"
      t.references :product, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
