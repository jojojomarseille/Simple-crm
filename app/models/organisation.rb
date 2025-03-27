class Organisation < ApplicationRecord
  mount_uploader :logo, OrganisationLogoUploader
end
