# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
AdminUser.create!(email: 'bourquardez.joachim@gmail.com', password: 'Password1', password_confirmation: 'Password1') if Rails.env.development?

AppConfig.find_or_create_by(key: 'maintenance_mode') do |config|
  config.value = 'false'
end

AppConfig.find_or_create_by(key: 'countdown_mode') do |config|
  config.value = 'false'
end

AppConfig.find_or_create_by(key: 'countdown_value') do |config|
  config.value = '0'
end