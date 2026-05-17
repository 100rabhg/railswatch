# frozen_string_literal: true

require 'action_view/log_subscriber'
require_relative 'rails/middleware'
require_relative 'models/collection'
require_relative 'instrument/metrics_collector'
require_relative 'system_monitor/resources_monitor'

module Railswatch
  class Engine < ::Rails::Engine
    isolate_namespace Railswatch

    isolate_assets assets_subdir: 'engine_assets'

    initializer 'railswatch.resource_monitor' do
      # check required gems are available
      Railswatch._resource_monitor_enabled =
        !(defined?(Sys::Filesystem) && defined?(Sys::CPU) && defined?(GetProcessMem)).nil?

      next unless Railswatch.enabled
      next if ::Rails.env.test?
      next if $railswatch_running_mode == :console # rubocop:disable Style/GlobalVars

      # start monitoring
      Railswatch._resource_monitor = Railswatch::SystemMonitor::ResourcesMonitor.new(
        ENV['RAILSWATCH_SERVER_CONTEXT'].presence || 'rails',
        ENV['RAILSWATCH_SERVER_ROLE'].presence || 'web'
      )
    end

    initializer 'railswatch.middleware' do |app|
      next unless Railswatch.enabled

      app.middleware.insert_after ActionDispatch::Executor, Railswatch::Rails::Middleware
      # look like it works in reverse order?
      app.middleware.insert_before(
        Railswatch::Rails::Middleware,
        Railswatch::Rails::MiddlewareTraceStorerAndCleanup
      )

      if defined?(::Sidekiq)
        require_relative 'gems/sidekiq_ext'

        Sidekiq.configure_server do |config|
          config.server_middleware do |chain|
            chain.add Railswatch::Gems::SidekiqExt
          end

          config.on(:startup) do
            if $railswatch_running_mode != :console # rubocop:disable Style/GlobalVars
              # stop web monitoring
              # when we run sidekiq it also starts web monitoring (see above)
              Railswatch._resource_monitor.stop_monitoring
              Railswatch._resource_monitor = nil
              # start background monitoring
              Railswatch._resource_monitor = Railswatch::SystemMonitor::ResourcesMonitor.new(
                ENV['RAILSWATCH_SERVER_CONTEXT'].presence || 'sidekiq',
                ENV['RAILSWATCH_SERVER_ROLE'].presence || 'background'
              )
            end
          end
        end
      end

      if defined?(::Grape)
        require_relative 'gems/grape_ext'
        Railswatch::Gems::GrapeExt.init
      end

      if defined?(::Delayed::Job)
        require_relative 'gems/delayed_job_ext'
        Railswatch::Gems::DelayedJobExt.init
      end
    end

    initializer :configure_metrics, after: :initialize_logger do
      next unless Railswatch.enabled

      ActiveSupport::Notifications.subscribe(
        'process_action.action_controller',
        Railswatch::Instrument::MetricsCollector.new
      )
    end

    config.after_initialize do
      next unless Railswatch.enabled

      Railswatch::Models::ApplicationRecord.reset_storage_connection!

      ActionView::LogSubscriber.prepend Railswatch::Extensions::View
      ActiveRecord::LogSubscriber.prepend Railswatch::Extensions::Db if defined?(ActiveRecord)

      if defined?(::Rake::Task) && Railswatch.include_rake_tasks
        require_relative 'gems/rake_ext'
        Railswatch::Gems::RakeExt.init
      end
    end

    if defined?(::Rails::Console)
      $railswatch_running_mode = :console # rubocop:disable Style/GlobalVars
    end
  end
end
