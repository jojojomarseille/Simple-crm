class PagesController < ApplicationController
    before_action :authenticate_user!, only: [:infos_user, :connected_home]
    def home
    end

    def connected_home
      if current_user && current_user.dashboard_blocks_order.present?
        @dashboard_blocks_order = current_user.dashboard_blocks_order
      end
    end

    def save_dashboard_order
      blocks_order = params[:blocks_order]
      
      # Enregistrer l'ordre pour l'utilisateur actuel si nécessaire
      current_user.update(dashboard_blocks_order: blocks_order)

      # Si l'utilisateur est connecté, enregistrer son ordre
      if current_user
        current_user.update(dashboard_blocks_order: blocks_order)
        render json: { success: true }
      else
        # Si pas connecté, juste confirmer que ça a été reçu
        render json: { success: true, message: "Ordre sauvegardé localement uniquement" }
      end
      
      # Pour le moment, simplement retourner un succès
      render json: { success: true }
    end

    def infos_user
      @user = current_user
      @organisation = @user.organisation
    end
    
end
