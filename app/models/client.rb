class Client < ApplicationRecord
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

  end 