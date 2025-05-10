ActiveAdmin.register Client do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  #permit_params :name, :client_type, :mail, :phone, :address, :city, :country, :postal_code, :latitude, :longitude, :organisation_id
  #
  # or
  #
  permit_params do
    permitted = [:name, :client_type, :mail, :phone, :address, :image, :city, :country, :postal_code, :latitude, :longitude, :organisation_id]
    permitted << :other if params[:action] == 'create' && current_user.admin?
    permitted
  end
  
end
