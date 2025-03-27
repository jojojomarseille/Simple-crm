class Organisation < ApplicationRecord
  mount_uploader :logo, OrganisationLogoUploader
  has_many :users
end
