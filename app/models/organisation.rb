class Organisation < ApplicationRecord
  mount_uploader :logo, OrganisationLogoUploader
  has_many :users
  belongs_to :base_company, optional: true
end
