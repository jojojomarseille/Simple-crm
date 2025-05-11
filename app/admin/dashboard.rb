# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end
    
    ActiveAdmin.register_page "Dashboard" do
      menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }
    
      content title: proc { I18n.t("active_admin.dashboard") } do
        # Statut des modes du système
        panel "État du système" do
          div class: "system-status-panel" do
            maintenance_mode = AppConfig.maintenance_mode?
            countdown_mode = AppConfig.countdown_mode?
            countdown_date = AppConfig.find_by(key: 'countdown_date')&.value
    
            div class: "status-items" do
              div class: "status-item" do
                status_class = maintenance_mode ? "status-on" : "status-off"
                span "Mode maintenance", class: "status-label"
                span class: "status-indicator #{status_class}" do
                  status_text = maintenance_mode ? "ACTIVÉ" : "Désactivé"
                  status_icon = maintenance_mode ? "✓" : "✗"
                  "#{status_icon} #{status_text}"
                end
              end
    
              div class: "status-item" do
                status_class = countdown_mode ? "status-on" : "status-off"
                span "Mode countdown", class: "status-label"
                span class: "status-indicator #{status_class}" do
                  status_text = countdown_mode ? "ACTIVÉ" : "Désactivé"
                  status_icon = countdown_mode ? "✓" : "✗"
                  "#{status_icon} #{status_text}"
                end
              end

            end
          end
        end
    
        # Ajoutez du CSS inline pour le style
        style do
          raw <<-CSS
            .system-status-panel {
              padding: 15px;
            }
            .status-items {
              display: flex;
              flex-direction: column;
              gap: 15px;
            }
            .status-item {
              display: flex;
              align-items: center;
              gap: 15px;
              padding: 10px 15px;
              background-color: #f5f5f5;
              border-radius: 5px;
            }
            .status-label {
              font-weight: bold;
              min-width: 180px;
            }
            .status-indicator {
              font-weight: bold;
              padding: 5px 10px;
              border-radius: 4px;
            }
            .status-on {
              background-color: #d4edda;
              color: #155724;
            }
            .status-off {
              background-color: #f8d7da;
              color: #721c24;
            }
            .countdown-value {
              color: #0c5460;
              background-color: #d1ecf1;
              padding: 5px 10px;
              border-radius: 4px;
            }
            .countdown-expired {
              color: #856404;
              background-color: #fff3cd;
              padding: 5px 10px;
              border-radius: 4px;
            }
            .countdown-error {
              color: #721c24;
              background-color: #f8d7da;
              padding: 5px 10px;
              border-radius: 4px;
            }
          CSS
        end
    
          
        end
      end
    
    



    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
