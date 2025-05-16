class CreateActiveAdminComments < ActiveRecord::Migration[7.0]
  def change
    create_table :active_admin_comments, id: :uuid do |t|
      t.string :namespace
      t.text :body
      t.string :resource_type
      t.uuid :resource_id
      t.string :author_type
      t.uuid :author_id

      t.timestamps
      
      t.index [:author_type, :author_id], name: 'index_active_admin_comments_on_author'
      t.index [:resource_type, :resource_id], name: 'index_active_admin_comments_on_resource'
      t.index :namespace
    end
  end
end
