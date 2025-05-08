module Api
  class BaseCompaniesController < ApplicationController
    # Permet un accès sans authentification pour cette action
    skip_before_action :authenticate_user!, only: [:search], if: -> { respond_to?(:authenticate_user!) }
    
    def search
      query = params[:query].to_s.downcase
      
      if query.length < 3
        render json: []
        return
      end
      
      # Recherche sur plusieurs champs
      companies = BaseCompany.where("LOWER(denomination_sociale) LIKE ? OR siret LIKE ? OR siren LIKE ?", 
      "%#{query}%", "%#{query}%", "%#{query}%").limit(6)
      
      results = companies.map do |company|
        {
          id: company.id,
          denomination_sociale: company.denomination_sociale,
          siret: company.siret,
          siren: company.siren,
          adresse: company.adresse,
          code_postal: company.code_postal
        }
      end
      
      render json: results
    end
    
    def show
      company = BaseCompany.find_by(id: params[:id])
      
      if company
        render json: {
          id: company.id,
          denomination_sociale: company.denomination_sociale,
          siret: company.siret,
          siren: company.siren,
          adresse: company.adresse,
          code_postal: company.code_postal,
          date_creation: company.date_creation
        }
      else
        render json: { error: "Entreprise non trouvée" }, status: :not_found
      end
    end

  end
end