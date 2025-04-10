namespace :db do
  desc "Seed database with sample companies"
  task seed_companies: :environment do
    # Supprimer les entreprises existantes pour éviter les doublons
    BaseCompany.delete_all

    # Créer 100 entreprises fictives
    100.times do
      FactoryBot.create(:base_company)
    end

    puts "Seeded 100 companies."
  end
end