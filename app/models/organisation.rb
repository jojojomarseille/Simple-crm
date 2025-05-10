class Organisation < ApplicationRecord
  mount_uploader :logo, OrganisationLogoUploader
  has_many :users
  has_many :products
  belongs_to :base_company, optional: true

  def self.ransackable_associations(auth_object = nil)
    %w[users products base_company]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id status creation_date business_name address address_line_2 postal_code city country identification_number vat_number created_at updated_at logo capital base_company_id]
  end
end
