# frozen_string_literal: true

require 'test_helper'
require 'rails/generators/test_case'
require 'generators/railswatch/install/install_generator'

class InstallGeneratorTest < Rails::Generators::TestCase
  tests Railswatch::InstallGenerator
  destination File.expand_path('tmp/install_generator', __dir__)
  setup :prepare_destination

  test 'generate railswatch install files' do
    run_generator

    assert_file 'config/initializers/railswatch.rb' do |content|
      assert_includes content, 'Railswatch.setup'
      assert_includes content, 'config.database_connection_name = nil'
    end

    migration = Dir[File.join(destination_root, 'db/migrate/*_create_railswatch_tables.rb')].first
    refute_nil migration

    assert_file migration do |content|
      assert_includes content, 'class CreateRailswatchTables'
      assert_includes content, 'create_table :railswatch_request_records'
      assert_includes content, 'create_table :railswatch_trace_records'
    end
  end
end
