class CreateAppConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :app_configs do |t|
      t.string :key, null: false
      t.string :value, null: false
      t.timestamps
    end
    
    add_index :app_configs, :key, unique: true
  end
end
