require 'rails_helper'

RSpec.configure do |config|
    Capybara.javascript_driver = :webkit

    Capybara::Webkit.configure do |config|
        config.allow_url("fonts.googleapis.com")
    end

    config.include FeatureMacros, type: :feature

    config.use_transactional_fixtures = false

    config.before(:suite) do
        DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do
        DatabaseCleaner.strategy = :transaction
    end

    config.before(:each, js: true) do
        DatabaseCleaner.strategy = :truncation
    end

    config.before(:each) do
        DatabaseCleaner.start
    end

    config.after(:each) do
        DatabaseCleaner.clean
    end
end