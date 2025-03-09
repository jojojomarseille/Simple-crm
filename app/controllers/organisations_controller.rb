class OrganisationsController < ApplicationController
  before_action :authenticate_user!

  def edit
    @organisation = current_user.organisation
  end

  def update
    @organisation = current_user.organisation
    if @organisation.update(organisation_params)
      redirect_to infos_user_path, notice: 'Informations de l\'organisation mises à jour avec succès.'
    else
      render :edit
    end
  end

  private

  def organisation_params
    params.require(:organisation).permit(:status, :creation_date, :business_name, :address, :address_line_2, :postal_code, :city, :country, :identification_number, :vat_number)
  end
end
