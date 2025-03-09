class PagesController < ApplicationController
    before_action :authenticate_user!, only: [:infos_user]
    def home
    end

    def infos_user
      @user = current_user
      @organisation = @user.organisation
    end
    
end
