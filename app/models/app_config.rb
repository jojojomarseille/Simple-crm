class AppConfig < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  
  def self.maintenance_mode?
    find_by(key: 'maintenance_mode')&.value == 'true'
  end
  
  def self.countdown_mode?
    find_by(key: 'countdown_mode')&.value == 'true'
  end
  
  def self.countdown_value
    find_by(key: 'countdown_value')&.value.to_i
  end
  
  after_save :ensure_exclusive_modes
  
  private
  
  def ensure_exclusive_modes
    if key == 'maintenance_mode' && value == 'true'
      AppConfig.find_by(key: 'countdown_mode')&.update(value: 'false')
    elsif key == 'countdown_mode' && value == 'true'
      AppConfig.find_by(key: 'maintenance_mode')&.update(value: 'false')
    end
  end
end
