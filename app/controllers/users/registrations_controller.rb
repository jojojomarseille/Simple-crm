# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create, :step2, :step3, :step4]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    @user = User.new
  end

  def step2
    session[:registration_params] ||= {}
    session[:registration_params].merge!(user_params.to_h)
    @user = User.new(session[:registration_params])
    render :new unless @user.valid?(:step1)
  end

  def step2_get
    puts "step2 GET called"
    if session[:registration_params].blank?
      redirect_to new_user_registration_path, alert: "Veuillez d'abord compléter l'étape 1"
      return
    end

    @user = User.new(session[:registration_params])
    render :step2
  end

  def step3
    puts "step 3"
    puts "registration_params: #{session[:registration_params]}"
    session[:registration_params].merge!(user_params.to_h)
    @user = User.new(session[:registration_params])
    @user.build_organisation unless @user.organisation
    render :step2 unless @user.valid?(:step2)
  end

  # Gère le GET pour step3
  def step3_get
    puts "step3 GET called"
    if session[:registration_params].blank?
      redirect_to new_user_registration_path, alert: "Veuillez d'abord compléter l'étape 1"
      return
    end
  
    @user = User.new(session[:registration_params])
    # Vérifiez si les étapes précédentes sont valides
    unless @user.valid?(:step1) && @user.valid?(:step2)
      redirect_to step2_users_registrations_get_path, alert: "Veuillez compléter correctement les étapes précédentes"
      return
    end
  
    render :step3
  end

  def step4
    puts "step 4"
    # puts "registration_params: #{session[:registration_params]}"
    # puts "user_params: #{user_params}"
    session[:registration_params].merge!(user_params.to_h)
    @user = User.new(session[:registration_params])
    
     # Si on a un ID d'entreprise, récupérer les données
    if params.dig(:user, :organisation_attributes, :base_company_id).present?
      base_company_id = params[:user][:organisation_attributes][:base_company_id]
      base_company = BaseCompany.find_by(id: base_company_id)
    
      if base_company
        # Stocker l'ID dans les paramètres de session
        session[:registration_params]["organisation_attributes"]["base_company_id"] = base_company_id
      
        # Rediriger vers le GET avec l'ID pour pré-remplissage
        redirect_to step4_users_registrations_get_path(base_company_id: base_company_id)
        return
      end
    end

    @user.build_organisation unless @user.organisation
    render :step3 unless @user.valid?(:step3)
  end

  # Gère le GET pour step4
  def step4_get
    puts "step4 GET called"
    if session[:registration_params].blank?
      redirect_to new_user_registration_path, alert: "Veuillez d'abord compléter l'étape 1"
      return
    end
  
    @user = User.new(session[:registration_params])
    # Vérifiez si les étapes précédentes sont valides
    unless @user.valid?(:step1) && @user.valid?(:step2) && @user.valid?(:step3)
      redirect_to step3_users_registrations_get_path, alert: "Veuillez compléter correctement les étapes précédentes"
      return
    end
  
    # Pré-remplir les champs si on a un ID d'entreprise
      base_company_id = params[:base_company_id] || session[:registration_params].dig("organisation_attributes", "base_company_id")
      if base_company_id.present?
        @base_company = BaseCompany.find_by(id: base_company_id)
        if @base_company
          # Pré-remplir les attributs de l'organisation
          @user.organisation ||= @user.build_organisation
          @user.organisation.assign_attributes(
            business_name: @base_company.denomination_sociale,
            identification_number: @base_company.siret,
            address: @base_company.adresse,
            postal_code: @base_company.code_postal,
            country: @base_company.pays,
            capital: @base_company.capital,
            city: @base_company.city,
            creation_date: @base_company.date_creation,
            # Autres champs selon les données disponibles
            base_company_id: @base_company.id
          )
        end
      end

    render :step4
  end

  def create
    puts "step create"
    # puts "registration_params avant merge: #{session[:registration_params]}"
    # puts "user_params: #{user_params}"
    # session[:registration_params].merge!(user_params.to_h)
    
    # Fusionner les attributs de l'utilisateur et de l'organisation
    session[:registration_params].merge!(user_params.to_h) do |key, old_val, new_val|
      if key.to_s == "organisation_attributes"
        old_val.merge(new_val)
      else
        new_val
      end
    end

    # puts "registration_params apres merge: #{session[:registration_params]}"
    @user = User.new(session[:registration_params])
    # puts "@user a ce stade: #{@user}"
    @user.status = 'org_admin'

    # Assurez-vous que l'ID de BaseCompany est bien assigné
    if session[:registration_params].dig("organisation_attributes", "base_company_id").present?
      base_company_id = session[:registration_params]["organisation_attributes"]["base_company_id"]
      @user.organisation.base_company_id = base_company_id
    end

    if @user.save
      session[:registration_params] = nil
      sign_in(@user)
      redirect_to connected_home_path, notice: 'Inscription réussie.'
    else
      render :step4
    end
  end

  def company_details
    base_company_id = params[:id]
    @base_company = BaseCompany.find_by(id: base_company_id)
    
    if @base_company
      render json: { 
        business_name: @base_company.denomination_sociale,
        identification_number: @base_company.siret,
        address: @base_company.adresse,
        postal_code: @base_company.code_postal,
        country: @base_company.pays,
        capital: @base_company.capital,
        city: @base_company.city,
        creation_date: @base_company.date_creation,
        base_company_id: @base_company.id
        # Autres champs selon votre modèle BaseCompany
      }
    else
      render json: { error: "Entreprise non trouvée" }, status: :not_found
    end
  end

  # def autocomplete
  #   query = params[:query]
  #   @base_companies = BaseCompany.where('name ILIKE ?', "%#{query}%").limit(6)
  #   render json: @base_companies.map { |company| { id: company.id, name: company.name } }
  # end
 
  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :phone, :status, :birthdate, organisation_attributes: [:status, :creation_date, :business_name, :capital, :logo, :address, :address_line_2, :postal_code, :city, :country, :identification_number, :vat_number]])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :firstname, :lastname, :birthdate, :phone,
                                 organisation_attributes: [:business_name, :status, :capital, :creation_date, :address, :address_line_2, :postal_code, :logo, :city, :country, :identification_number, :vat_number, :base_company_id])
  end

end
