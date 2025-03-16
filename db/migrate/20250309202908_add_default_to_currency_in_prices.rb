class AddDefaultToCurrencyInPrices < ActiveRecord::Migration[7.0]
  def change
    change_column_default :prices, :currency, from: nil, to: "Euros"
  end
end
