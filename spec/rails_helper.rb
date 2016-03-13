ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'

ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.include Devise::TestHelpers, type: :controller
    config.include FactoryGirl::Syntax::Methods
    config.include Capybara::DSL

    config.extend ControllerMacros, type: :controller

    include Warden::Test::Helpers
    Warden.test_mode!

    config.use_transactional_fixtures = true

    config.infer_spec_type_from_file_location!

    config.filter_rails_from_backtrace!

    config.after :each do
        Warden.test_reset!
    end
end

Shoulda::Matchers.configure do |config|
    config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
    end
end