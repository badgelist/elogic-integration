source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
ruby '2.5.1'

#=== CORE GEMS & OPS===#

  gem 'rails', '~> 5.2.0'
  gem 'puma', '~> 3.11'
  gem 'bootsnap', '>= 1.1.0', require: false
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

#=== STORAGE & CACHING ===#

  gem 'mysql2'
  gem 'rails-settings-cached'

#=== AUTHENTICATION ===#
  
  gem 'clearance'

#=== EXTERNAL WEB SERVICES ===#

  gem 'savon', '~> 2.12.0'
  
#=== FRONT-END ===#

  gem 'sass-rails', '~> 5.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'coffee-rails', '~> 4.2'
  gem 'turbolinks', '~> 5'

#=== DEVELOPMENT / TEST ===#

  group :development, :test do
    gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
    gem 'capistrano-rails'
    gem 'rspec-rails'
    gem 'database_cleaner'
    gem 'factory_bot_rails'
    gem 'faker'
    gem 'shoulda-matchers'
    gem 'simplecov', require: false
  end

  group :development do
    gem 'web-console', '>= 3.3.0'
    gem 'better_errors'
    gem 'binding_of_caller'
    gem 'listen', '>= 3.0.5', '< 3.2'
    gem 'spring'
    gem 'spring-watcher-listen', '~> 2.0.0'
  end
  
  group :test do
    gem 'capybara', '>= 2.15', '< 4.0'
    gem 'selenium-webdriver'
    gem 'chromedriver-helper'
  end