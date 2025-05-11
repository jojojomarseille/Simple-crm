class Client < ApplicationRecord
  belongs_to :organisation
  has_many :orders, dependent: :destroy
    # Spécifiez les champs qui, combinés, forment l'adresse complète utilisée pour le géocodage
    geocoded_by :full_address
  
    # Exécute le géocodage après la validation si l'adresse (ou l'un de ses composants) change
    after_validation :geocode
  
    # Définissez une méthode pour construire l'adresse complète pour le géocodage
    def full_address
      [address, city, postal_code, country].compact.join(', ')
    end
  
    validates :name, presence: true
    validates :client_type, presence: true
    validates :mail, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    mount_uploader :image, ImageUploader 
    
    def self.ransackable_associations(auth_object = nil)
      ["orders", "organisation"] # Liste tes associations autorisées ici
    end
  
    # Méthode pour permettre les attributs recherchables (facultatif, mais souvent utile)
    def self.ransackable_attributes(auth_object = nil)
      %w[id name client_type mail phone address created_at updated_at city country postal_code latitude longitude organisation_id image]
    end

end 