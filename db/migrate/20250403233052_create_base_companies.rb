class CreateBaseCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :base_companies do |t|
      t.string :siret
      t.string :siren
      t.string :denomination_sociale
      t.string :marque
      t.string :adresse
      t.string :code_postal
      t.string :statut
      t.string :pays
      t.datetime :date_derniere_modification
      t.datetime :date_creation

      t.timestamps
    end
  end
end
