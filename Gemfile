source 'https://rubygems.org'

ruby '2.3.1'

gem 'jquery-rails'
gem 'rails', '~> 5.1.2'
gem 'therubyracer', platforms: :ruby

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.20'

# Use Puma as the app server
gem 'puma', '~> 3.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Store secrets
gem 'figaro'

# Bootstrap for frontend
gem 'bootstrap-sass', '~> 3.2.0'

# Auto-prefixing CSS for cross-browser compat.
gem 'autoprefixer-rails', '6.7.6'

# Use Slim as the templating engine. Better than ERB
gem 'slim'

# Authentication
gem 'devise', github: 'plataformatec/devise'

# Form creator
gem 'simple_form', '~> 3.5'

# Model Serializers
gem 'active_model_serializers'
gem 'oj'
gem 'oj_mimic_json'

# API Auth
gem 'doorkeeper'

# API documentation
gem 'apipie-rails'

# Social networks auth
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-vkontakte'

# Rails admin panel
gem 'rails_admin'

# Rails localization
gem 'route_translator'

# Webpack and React
gem 'foreman'
gem 'webpacker'
gem 'webpacker-react', '~> 0.3.1'

# Code analyzation
gem 'rubocop', '~> 0.49.1', require: false

group :development, :test do
    gem 'factory_girl_rails'
    gem 'rails-controller-testing'
    gem 'rspec-rails'
end

group :development do
    gem 'capistrano', require: false
    gem 'capistrano-bundler', require: false
    gem 'capistrano-rails', require: false
    gem 'capistrano-rvm', require: false
    gem 'capistrano-sidekiq', require: false
    gem 'listen', '~> 3.0.5'
    gem 'spring'
    gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
    gem 'json_spec'
    gem 'shoulda-matchers'
end
