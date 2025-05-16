# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# AdminUser.create!(email: 'bourquardez.joachim@gmail.com', password: 'Password1', password_confirmation: 'Password1') if Rails.env.development?
# if Rails.env.development? 
#   AdminUser.create!(email: 'bourquardez.joachim@gmail.com', password: 'Password1', password_confirmation: 'Password1')
# elsif Rails.env.production? && ENV['SEED_ADMIN_EMAIL'].present? && ENV['SEED_ADMIN_PASSWORD'].present?
#   AdminUser.create!(
#     email: ENV['SEED_ADMIN_EMAIL'],
#     password: ENV['SEED_ADMIN_PASSWORD'],
#     password_confirmation: ENV['SEED_ADMIN_PASSWORD']
#   )
# end
 

#pour generer des companies fictives, uniquement en environnement de dev
# Chargement des tâches Rake
# Rails.application.load_tasks
# Appel de la tâche pour générer les entreprises fictives
# Rake::Task['db:seed_companies'].invoke
# puts "Tous les tacjhes rake des seeds ont été chargés avec succès, y compris les 100 entreprises fictives."

AppConfig.find_or_create_by(key: 'maintenance_mode') do |config|
  config.value = 'false'
end

AppConfig.find_or_create_by(key: 'countdown_mode') do |config|
  config.value = 'false'
end

AppConfig.find_or_create_by(key: 'countdown_value') do |config|
  config.value = '0'
end