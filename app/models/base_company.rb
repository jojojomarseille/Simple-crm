class BaseCompany < ApplicationRecord
    # Méthode pour définir les associations recherchables
  def self.ransackable_associations(auth_object = nil)
    ["organization"] # Si une organisation peut être liée à une BaseCompany
  end
  
  # Méthode pour définir les attributs recherchables
  def self.ransackable_attributes(auth_object = nil)
    %w[id siret siren denomination_sociale marque adresse code_postal city pays statut date_derniere_modification date_creation created_at updated_at capital]
  end
end
