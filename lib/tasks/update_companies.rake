namespace :companies do
  desc "Ajoute capital et city aux BaseCompany existantes qui n'ont pas ces données"
  task update_missing_fields: :environment do
    puts "Mise à jour des BaseCompany..."
    
    companies_updated = 0
    BaseCompany.where(capital: nil).or(BaseCompany.where(city: nil)).find_each do |company|
      company.capital ||= rand(1000..100000) / 100.0 # Génère un capital entre 10.00 et 1000.00
      company.city ||= Faker::Address.city
      company.save
      companies_updated += 1
      print "." if companies_updated % 100 == 0 # Affiche un point tous les 100 enregistrements
    end
    
    puts "\nTerminé! #{companies_updated} entreprises mises à jour."
  end
end
