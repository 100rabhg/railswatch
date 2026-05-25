# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'railswatch/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name = 'railswatch'
  spec.version = Railswatch::VERSION
  spec.authors = ['Sourabh Patware']
  spec.email = ['sourabhpatware100@gmail.com']
  spec.homepage = 'https://github.com/100rabhg/railswatch'
  spec.summary = 'Simple Railswatch tracker. Alternative to the NewRelic, Datadog or other services.'
  spec.description = '3rd party dependency-free solution how to monitor performance of your Rails applications.'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'activerecord'
  spec.add_dependency 'browser'
  spec.add_dependency 'csv'
  spec.add_dependency 'isolate_assets', '~> 0.3.0'
  spec.add_dependency 'railties'

  spec.add_development_dependency 'actionmailer'
  spec.add_development_dependency 'activestorage'
  spec.add_development_dependency 'daemons'
  spec.add_development_dependency 'delayed_job_active_record'
  spec.add_development_dependency 'get_process_mem'
  spec.add_development_dependency 'grape'
  spec.add_development_dependency 'mimemagic', '0.4.3'
  spec.add_development_dependency 'puma'
  spec.add_development_dependency 'sidekiq'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sprockets-rails'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'sys-cpu'
  spec.add_development_dependency 'sys-filesystem'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
