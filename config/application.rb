require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ElogicIntegration
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.action_mailer.default_url_options = { :host => ENV['root_domain'] }
    
    # Add the base smtp settings for gmail if the gmail_password environment variable is set
    if ENV['gmail_password'].present?
      config.action_mailer.delivery_method = :smtp # this gets overridden in test.rb
      config.action_mailer.smtp_settings = {
        address:              'smtp.gmail.com',
        port:                 587,
        user_name:            ENV['from_email'],
        password:             ENV['gmail_password'],
        authentication:       'plain',
        enable_starttls_auto: true
      }
    end
  end
end
