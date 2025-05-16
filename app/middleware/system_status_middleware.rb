class SystemStatusMiddleware
  def initialize(app)
    @app = app
  end
  
  def call(env)
    request = Rack::Request.new(env)
    
    return @app.call(env) if admin_route?(request)
    return @app.call(env) if static_resource?(request)
    
    if AppConfig.maintenance_mode?
      return @app.call(env) if request.path == '/maintenance'
      return [302, {'Location' => '/maintenance', 'Content-Type' => 'text/html'}, []]
    end
    
    if AppConfig.countdown_mode?
      return @app.call(env) if request.path == '/countdown'
      return [302, {'Location' => '/countdown', 'Content-Type' => 'text/html'}, []]
    end

    if request.path == '/maintenance' || request.path == '/countdown'
      return [302, {'Location' => '/', 'Content-Type' => 'text/html'}, []]
    end

    @app.call(env)
  end
  
  private
  
  def admin_route?(request)
    return true if request.path.start_with?('/admin')
    admin_user_id = request.session['warden.user.admin_user.key']&.flatten&.first
    return false unless admin_user_id
    
    AdminUser.exists?(admin_user_id)
  end

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