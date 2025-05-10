class Price < ApplicationRecord
  belongs_to :product

  def self.ransackable_associations(auth_object = nil)
    %w[product]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id amount currency product_id created_at updated_at]
  end
end
