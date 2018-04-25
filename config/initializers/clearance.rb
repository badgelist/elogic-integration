Clearance.configure do |config|
    
  config.allow_sign_up = false # since all users have the same access we need to manually create new users

  config.cookie_domain = ENV['root_domain']
  config.cookie_expiration = lambda { |cookies| 1.year.from_now.utc }

  config.routes = false # it is recommended to handle these ourself so as to ensure stability of url structure
  
  config.mailer_sender = ENV['from_email']

  config.rotate_csrf_on_sign_in = true

end
