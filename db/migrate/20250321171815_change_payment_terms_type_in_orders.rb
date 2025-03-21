class ChangePaymentTermsTypeInOrders < ActiveRecord::Migration[7.0]
    def up
      # Ajouter une nouvelle colonne temporaire pour stocker les valeurs converties
      add_column :orders, :payment_terms_integer, :integer
  
      # Convertir les valeurs existantes de string à integer
      Order.reset_column_information
      Order.find_each do |order|
        order.update(payment_terms_integer: order.payment_terms.to_i) if order.payment_terms.present?
      end
  
      # Supprimer l'ancienne colonne
      remove_column :orders, :payment_terms, :string
  
      # Renommer la nouvelle colonne pour qu'elle prenne le nom de l'ancienne
      rename_column :orders, :payment_terms_integer, :payment_terms
    end
  
    def down
      # Ajouter une nouvelle colonne temporaire pour stocker les valeurs converties
      add_column :orders, :payment_terms_string, :string
  
      # Convertir les valeurs existantes d'integer à string
      Order.reset_column_information
      Order.find_each do |order|
        order.update(payment_terms_string: order.payment_terms.to_s) if order.payment_terms.present?
      end
  
      # Supprimer l'ancienne colonne
      remove_column :orders, :payment_terms, :integer
  
      # Renommer la nouvelle colonne pour qu'elle prenne le nom de l'ancienne
      rename_column :orders, :payment_terms_string, :payment_terms
    end
end
