class AddCapitalAndCityToBaseCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :base_companies, :capital, :decimal, precision: 15, scale: 2
    add_column :base_companies, :city, :string
  end
end
