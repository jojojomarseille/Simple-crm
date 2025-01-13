class Client < ApplicationRecord
    validates :name, presence: true
    validates :client_type, presence: true
    validates :mail, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    mount_uploader :image, ImageUploader 
  end
  