class Order < ApplicationRecord
  before_save :set_payment_due_date, if: :status_changed_to_validated?
  before_save :set_id_by_org, if: :status_changed_to_validated?


  belongs_to :client
  belongs_to :organisation
  has_many :order_items, inverse_of: :order, dependent: :destroy
  has_many :products, through: :order_items
  accepts_nested_attributes_for :order_items, allow_destroy: true 

  before_save :calculate_total_price_ht
  STATES = ["brouillon", "validé"]
  validates :status, inclusion: { in: STATES }
  validates :payment_terms, numericality: { only_integer: true }

  TERMS = [0, 15, 30, 45, 90]
   
  private

  def set_id_by_org
    if status == 'validé'
      puts "set_id_by_org est appelé"
      last_order = Order.where(organisation_id: organisation_id, status: 'validé').order(id_by_org: :desc).first
      puts "last order: #{last_order.inspect} and last order id by org: #{last_order.id_by_org}"
      self.id_by_org = last_order.id_by_org.nil? ? 1 : last_order.id_by_org + 1 
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

end
