FactoryBot.define do
  factory :base_company do
    siret { Faker::Number.number(digits: 14) }
    siren { Faker::Number.number(digits: 9) }
    denomination_sociale { Faker::Company.name }
    marque { Faker::Company.name }
    adresse { Faker::Address.street_address }
    code_postal { Faker::Address.postcode }
    statut { Faker::Company.suffix }
    pays { 'France' }
    date_derniere_modification { Faker::Date.between(from: 2.years.ago, to: Date.today) }
    date_creation { Faker::Date.between(from: 10.years.ago, to: 2.years.ago) }
  end
end