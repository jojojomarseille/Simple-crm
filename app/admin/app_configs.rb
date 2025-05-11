ActiveAdmin.register_page "App Settings" do
  menu priority: 1, label: "Paramètres système"
  
  content title: "Paramètres système" do
    div class: "system-settings" do
      panel "Mode de maintenance" do
        is_maintenance_mode = AppConfig.maintenance_mode?
        div class: "toggle-container" do
          toggle_url = is_maintenance_mode ? 
            admin_app_settings_toggle_maintenance_path(enable: false) : 
            admin_app_settings_toggle_maintenance_path(enable: true)
          
          para "État actuel : #{is_maintenance_mode ? 'Activé' : 'Désactivé'}"
          a href: toggle_url, class: "button #{is_maintenance_mode ? 'red' : 'green'}" do
            is_maintenance_mode ? "Désactiver" : "Activer"
          end
        end
      end
      
      panel "Mode compte à rebours" do
        is_countdown_mode = AppConfig.countdown_mode?
        div class: "toggle-container" do
          toggle_url = is_countdown_mode ? 
            admin_app_settings_toggle_countdown_path(enable: false) : 
            admin_app_settings_toggle_countdown_path(enable: true)
          
          para "État actuel : #{is_countdown_mode ? 'Activé' : 'Désactivé'}"
          a href: toggle_url, class: "button #{is_countdown_mode ? 'red' : 'green'}" do
            is_countdown_mode ? "Désactiver" : "Activer"
          end
        end
        
        div class: "countdown-settings" do
          render partial: "admin/app_settings/countdown_form"
        end
      end
    end
  end
  
  page_action :toggle_maintenance, method: :get do
    setting = AppConfig.find_by(key: 'maintenance_mode')
    new_value = params[:enable] == 'true' ? 'true' : 'false'
    setting.update(value: new_value)
    
    redirect_to admin_app_settings_path, notice: "Mode maintenance #{new_value == 'true' ? 'activé' : 'désactivé'}"
  end
  
  page_action :toggle_countdown, method: :get do
    setting = AppConfig.find_by(key: 'countdown_mode')
    new_value = params[:enable] == 'true' ? 'true' : 'false'
    setting.update(value: new_value)
    
    redirect_to admin_app_settings_path, notice: "Mode compte à rebours #{new_value == 'true' ? 'activé' : 'désactivé'}"
  end
  
  page_action :update_countdown, method: :post do
    setting = AppConfig.find_by(key: 'countdown_value')
    
    # Convertir en secondes
    days = params[:days].to_i
    hours = params[:hours].to_i
    minutes = params[:minutes].to_i
    seconds = params[:seconds].to_i
    
    total_seconds = days * 86400 + hours * 3600 + minutes * 60 + seconds
    
    setting.update(value: total_seconds.to_s)
    
    redirect_to admin_app_settings_path, notice: "Valeur du compte à rebours mise à jour"
  end
end
