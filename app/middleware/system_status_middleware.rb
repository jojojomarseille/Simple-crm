class SystemStatusMiddleware
  def initialize(app)
    @app = app
  end
  
  # def call(env)
  #   request = Rack::Request.new(env)
    
  #   if request.path.start_with?('/assets/', '/admin/', '/rails/') || request.path == '/active_storage/blobs/'
  #     return @app.call(env)
  #   end
    
  #   if AppConfig.maintenance_mode?
  #     return redirect_to('/maintenance')
  #   elsif AppConfig.countdown_mode?
  #     return redirect_to('/countdown')
  #   end
    
  #   @app.call(env)
  # end
  
  def call(env)
    request = Rack::Request.new(env)
    
      # 1. Pour les administrateurs, tout est accessible
    return @app.call(env) if admin_route?(request)
    
    # 2. Ressources statiques toujours accessibles
    return @app.call(env) if static_resource?(request)
    
    # 3. Vérifier si le site est en maintenance
    if AppConfig.maintenance_mode?
      # Si déjà sur la page maintenance, afficher normalement
      return @app.call(env) if request.path == '/maintenance'
      
      # Sinon, rediriger vers la page maintenance (même depuis countdown)
      return [302, {'Location' => '/maintenance', 'Content-Type' => 'text/html'}, []]
    end
    
    # 4. Vérifier si le site est en mode countdown
    if AppConfig.countdown_mode?
      # Si déjà sur la page countdown, afficher normalement
      return @app.call(env) if request.path == '/countdown'
      
      # Sinon, rediriger vers la page countdown (même depuis maintenance)
      return [302, {'Location' => '/countdown', 'Content-Type' => 'text/html'}, []]
    end

    # 5. En mode normal, empêcher l'accès direct aux pages spéciales
    if request.path == '/maintenance' || request.path == '/countdown'
      return [302, {'Location' => '/', 'Content-Type' => 'text/html'}, []]
    end

    # 6. Si aucun mode spécial n'est actif, continuer normalement
    @app.call(env)
  end
  
  private
  
  def admin_route?(request)
    # Vérifier si la route est une route d'administration
    return true if request.path.start_with?('/admin')
    
    # Vérifier si l'utilisateur est un administrateur connecté
    admin_user_id = request.session['warden.user.admin_user.key']&.flatten&.first
    return false unless admin_user_id
    
    AdminUser.exists?(admin_user_id)
  end

  # Vérifier si le chemin est exclus des redirections
  def static_resource?(request)
    static_paths = [
      '/assets', 
      '/packs', 
      '/images',
      '/favicon.ico', 
      '/robots.txt',
      '/hotwire-livereload'
    ]
    
    static_paths.any? { |path| request.path.start_with?(path) }
  end
end