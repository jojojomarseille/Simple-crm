class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  belongs_to :organisation, optional: true
  accepts_nested_attributes_for :organisation
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :orders, dependent: :destroy

  # validates :status, inclusion: { in: ['org_admin', 'collaborateur'] }, allow_nil: false

  # before_validation :set_default_status, on: :create

  def collaborateur?
    status == 'collaborateur'
  end

  def org_admin?
    status == 'org_admin'
  end

  def self.ransackable_associations(auth_object = nil)
    %w[organisation orders]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id email reset_password_token firstname lastname phone birthdate status organisation_id created_at updated_at]
  end

  def set_default_status
    puts "set_defult_status called"
    self.status ||= 'collaborateur' # Définir une valeur par défaut avant la validation
  end
end
