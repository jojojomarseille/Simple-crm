namespace :index do
  desc "Index all companies to Elasticsearch"
  task companies: :environment do
    BaseCompany.import
  end
end