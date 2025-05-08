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
    capital { Faker::Number.decimal(l_digits: 4, r_digits: 2) } # Génère un nombre comme 1234.56
    city { Faker::Address.city } # Génère un nom de ville aléatoire
  end
end