class Organisation < ApplicationRecord
  mount_uploader :logo, OrganisationLogoUploader
  has_many :users
  has_many :products
  belongs_to :base_company, optional: true
end
