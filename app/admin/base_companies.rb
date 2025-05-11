ActiveAdmin.register BaseCompany do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :siret, :siren, :denomination_sociale, :marque, :adresse, :code_postal, :statut, :pays, :date_derniere_modification, :date_creation, :capital, :city
  #
  # or
  #
  permit_params do
    permitted = [:siret, :siren, :denomination_sociale, :marque, :adresse, :code_postal, :statut, :pays, :date_derniere_modification, :date_creation, :capital, :city]
    permitted << :other if params[:action] == 'create' && current_user.admin?
    permitted
  end
  
end
