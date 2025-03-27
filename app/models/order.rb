class Order < ApplicationRecord
  before_save :set_payment_due_date, if: :status_changed_to_validated?
  before_save :set_id_by_org, if: :status_changed_to_validated?
  before_save :calculate_total_price_ht
  before_save :set_validation_date
  before_save :set_payment_date

  belongs_to :client
  belongs_to :organisation

  has_many :order_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :order_items

  accepts_nested_attributes_for :order_items, allow_destroy: true 

  STATES = ["brouillon", "validé"]
  PAYMENT_STATUSES = ['Payé', 'En attente'].freeze
  TERMS = [0, 15, 30, 45, 90]

  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :status, inclusion: { in: STATES }
  validates :payment_terms, numericality: { only_integer: true }



  def paid?
    payment_status == 'Payé'
  end

  def pending?
    payment_status == 'En attente'
  end
   
  private

  def set_id_by_org
    if status == 'validé'
      last_order = Order.where(organisation_id: organisation_id, status: 'validé').order(id_by_org: :desc).first
      if last_order.nil?
        self.id_by_org = 1
      else
        self.id_by_org = last_order.id_by_org.nil? ? 1 : last_order.id_by_org + 1 
      end
    end
  end

  def calculate_total_price_ht
    self.total_price_ht = order_items.sum { |item| item.price.to_f * item.quantity.to_i }
  end

  def set_payment_due_date
    self.payment_due_date = date + payment_terms.days if date && payment_terms
  end

  def status_changed_to_validated?
    status_changed? && status == 'validé' && status_was == 'brouillon'
  end

  def set_validation_date
    if status_changed? && status == 'validé'
      self.validation_date = Time.current
    end
  end
  
  def set_payment_date
    puts "set_paymentdate hited"
    if payment_status_changed? && payment_status == 'Payé'
      self.payment_date = Time.current
    end
  end

end
