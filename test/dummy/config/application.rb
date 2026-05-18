# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Pre-load devise (which also loads warden) before Bundler.require so that
# warden_compat.rb's redefinitions of request/reset_session! and devise's
# redefinition of default_url_options all happen once here, silently.
# Bundler.require then treats these gems as already-loaded no-ops.
begin
  saved_verbose = $VERBOSE
  $VERBOSE = nil
  require 'devise'
ensure
  $VERBOSE = saved_verbose
end

Bundler.require(*Rails.groups)
require 'railswatch'

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults Rails::VERSION::STRING.to_f

    config.time_zone = 'Europe/Kyiv'

    config.hosts.clear

    config.paths.add 'app/api', glob: '**/*.rb'
    config.autoload_paths += Dir["#{Rails.root}/app/api/*"]
    config.eager_load_paths += Dir["#{Rails.root}/app/api/*"]

    # Devise::FailureApp is autoloaded lazily and triggers a method-redefinition
    # warning (default_url_options) when first referenced. Force-load it here,
    # after routes are available, with warnings silenced.
    config.after_initialize do
      saved_verbose = $VERBOSE
      $VERBOSE = nil
      Devise.const_get(:FailureApp)
      $VERBOSE = saved_verbose
    end
  end
end
