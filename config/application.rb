require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Rcs
    class Application < Rails::Application
        # Use the responders controller from the responders gem
        config.app_generators.scaffold_controller :responders_controller

        config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
        I18n.available_locales = [:en, :ru]
        config.i18n.default_locale = :en
        config.active_record.raise_in_transactional_callbacks = true
        config.active_record.schema_format = :ruby
        config.generators do |g|
            g.test_framework :rspec, fixtures: true, views: false, view_specs: false, helper_specs: false,
                routing_specs: false, controller_specs: true, request_specs: false
            g.fixture_replacement :factory_girl, dir: 'spec/factories'
        end
    end
end
