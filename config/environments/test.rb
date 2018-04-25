Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # This enables the Clearance test helpers to sign in users
  config.middleware.use Clearance::BackDoor

  config.cache_classes = true
  config.eager_load = false

  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory
  config.active_storage.service = :test

  config.action_mailer.perform_caching = false

  # The :test delivery method accumulates sent emails in the ActionMailer::Base.deliveries array instead of sending them
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

end
