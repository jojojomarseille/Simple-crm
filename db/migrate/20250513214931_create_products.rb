class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products, id: :uuid do |t|
      t.string :name
      t.text :description
      t.string :product_image
      t.references :organisation, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
