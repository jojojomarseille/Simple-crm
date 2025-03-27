namespace :update_user_statuses do
  desc "Set the first user of each organization as org_admin and remove users without an organization"
  task set_org_admins_and_clean: :environment do
    # Mettre à jour le statut des utilisateurs
    Organisation.find_each do |organisation|
      first_user = organisation.users.order(:created_at).first
      if first_user
        first_user.update(status: 'org_admin')
        puts "Updated user #{first_user.id} to org_admin for organisation #{organisation.id}"
      end
    end

    # Supprimer les utilisateurs sans organisation
    User.where(organisation_id: nil).destroy_all
    puts "Removed all users without an organization"
  end
end
