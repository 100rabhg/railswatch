# frozen_string_literal: true

require 'rails/generators/migration'

module Railswatch
  class InstallGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration

    source_root File.expand_path('templates', __dir__)
    desc 'Generates initial config for railswatch gem'

    def copy_initializer_file
      copy_file 'initializer.rb', 'config/initializers/railswatch.rb'
    end

    def install_migration
      migration_template(
        'create_railswatch_tables.rb',
        'db/migrate/create_railswatch_tables.rb'
      )
    end

    def show_database_setup # rubocop:disable Metrics/MethodLength
      say <<~TEXT

        railswatch was configured with database-backed storage.

        Primary database:
          Leave `config.database_connection_name = nil`.
          Run `bin/rails db:migrate`.

        Separate database:
          1. Add a `railswatch` database entry to `config/database.yml`
          2. Set `config.database_connection_name = :railswatch`
          3. Run `bin/rails db:migrate` for your app database
          4. Run `bin/rails db:migrate:railswatch`

        You can prune old data later with `bin/rails railswatch:prune`.
      TEXT
    end

    def self.next_migration_number(_dirname)
      Time.now.utc.strftime('%Y%m%d%H%M%S')
    end
  end
end
