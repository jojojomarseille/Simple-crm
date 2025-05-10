ActiveAdmin.register Order do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :date, :client_id, :user_id, :total_price_ht, :organisation_id, :status, :payment_terms, :payment_due_date, :id_by_org, :payment_status, :validation_date, :payment_date
  #
  # or
  #
  permit_params do
    permitted = [:date, :client_id, :user_id, :total_price_ht, :organisation_id, :status, :payment_terms, :payment_due_date, :id_by_org, :payment_status, :validation_date, :payment_date]
    permitted << :other if params[:action] == 'create' && current_user.admin?
    permitted
  end
  
end
