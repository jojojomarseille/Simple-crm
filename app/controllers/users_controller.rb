class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_org_admin!, only: [:index, :new_collaborator, :create_collaborator]
  before_action :set_organisation, only: [:index, :new_collaborator, :create_collaborator]
  


  #quand la fiche user etait dans les parametres avec orga
  # def edit
  #   @user = current_user
  # end

# def update
#   @user = current_user
#   if @user.update(user_params)
#     redirect_to infos_user_path, notice: 'Informations utilisateur mises à jour avec succès.'
#   else
#     render :edit
#   end
# end

  def index
    order = params[:order] || 'firstname'  
    direction = params[:direction] || 'asc' 
    @per_page = params[:per_page] || 10
    valid_order_attributes = %w[id firstname lastname status]

    if valid_order_attributes.include?(order) && %w[asc desc].include?(direction)
      @clients = Client.where(organisation_id: @organisation.id)
                       .order("#{order} #{direction}")
                       .page(params[:page]).per(@per_page)
    else
      @clients = Client.where(organisation_id: @organisation.id)
                       .page(params[:page]).per(@per_page)
    end

    @users = User.where(organisation_id: @organisation.id)
                 .order("#{order} #{direction}")
                 .page(params[:page]).per(@per_page)
    
  end



  def new_collaborator
    @user = User.new
  end

  def create_collaborator
    @user = User.new(user_params)
    @user.organisation_id = @organisation.id
    @user.status = 'collaborateur'

    if @user.save
      redirect_to users_index_path, notice: 'Collaborateur ajouté avec succès.'
    else
      render :new_collaborator
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to users_index_path, notice: 'Utilisateur mis à jour avec succès.'
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_index_path, notice: 'Utilisateur supprimé avec succès.'
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :phone, :birthdate, :email, :status, :password, :password_confirmation)
  end

  def set_organisation
    @organisation = current_user.organisation
  end

  def authorize_org_admin!
    unless current_user.org_admin?
      flash[:alert] = "Vous n'avez pas les droits nécessaires pour accéder à cette page."
      redirect_to root_path
    end
  end
  
end
