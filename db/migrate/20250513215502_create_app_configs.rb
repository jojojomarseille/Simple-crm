class CreateAppConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :app_configs, id: :uuid do |t|
      t.string :key, null: false
      t.string :value, null: false

      t.timestamps
      
      t.index :key, unique: true
    end
  end
end
