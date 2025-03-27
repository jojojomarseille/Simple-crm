# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super do
      build_organisation
    end
  end

  def create
    super do |resource|
      if resource.persisted?
        # Sauvegarder l'organisation associée
        resource.organisation.save if resource.organisation

        # Définir le statut de l'utilisateur
        if resource.organisation.users.count == 1
          resource.update(status: 'org_admin')
        else
          resource.update(status: 'collaborateur')
        end
      end
    end
  end

 
  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :phone, :status, :birthdate, organisation_attributes: [:status, :creation_date, :business_name, :capital, :address, :address_line_2, :postal_code, :city, :country, :identification_number, :vat_number]])
  end

  def build_organisation
    puts "Building organisation appelé"
    resource.build_organisation unless resource.organisation
    puts resource.organisation.inspect
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
