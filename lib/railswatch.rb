# frozen_string_literal: true

require 'active_record'
require 'browser'
require 'active_support/core_ext/integer'
require_relative 'railswatch/version'
require_relative 'railswatch/rails/query_builder'
require_relative 'railswatch/rails/middleware'
require_relative 'railswatch/models/application_record'
require_relative 'railswatch/models/base_record'
require_relative 'railswatch/models/request_record'
require_relative 'railswatch/models/sidekiq_record'
require_relative 'railswatch/models/delayed_job_record'
require_relative 'railswatch/models/grape_record'
require_relative 'railswatch/models/trace_record'
require_relative 'railswatch/models/rake_record'
require_relative 'railswatch/models/resource_record'
require_relative 'railswatch/models/custom_record'
require_relative 'railswatch/models/event_record'
require_relative 'railswatch/data_source'
require_relative 'railswatch/utils'
require_relative 'railswatch/reports/base_report'
require_relative 'railswatch/reports/requests_report'
require_relative 'railswatch/reports/crash_report'
require_relative 'railswatch/reports/response_time_report'
require_relative 'railswatch/reports/throughput_report'
require_relative 'railswatch/reports/recent_requests_report'
require_relative 'railswatch/reports/slow_requests_report'
require_relative 'railswatch/reports/breakdown_report'
require_relative 'railswatch/reports/trace_report'
require_relative 'railswatch/reports/percentile_report'
require_relative 'railswatch/reports/resources_report'
require_relative 'railswatch/reports/annotations_report'
require_relative 'railswatch/reports/overview_report'
require_relative 'railswatch/events/record'
require_relative 'railswatch/widgets/base'
require_relative 'railswatch/widgets/chart'
require_relative 'railswatch/widgets/card'
require_relative 'railswatch/widgets/table'
require_relative 'railswatch/widgets/throughput_chart'
require_relative 'railswatch/widgets/response_time_chart'
require_relative 'railswatch/widgets/percentile_card'
require_relative 'railswatch/widgets/resource_chart'
require_relative 'railswatch/widgets/requests_table'
require_relative 'railswatch/widgets/recent_requests_table'
require_relative 'railswatch/widgets/crashes_table'
require_relative 'railswatch/widgets/slow_requests_table'
require_relative 'railswatch/widgets/sidekiq_jobs_table'
require_relative 'railswatch/widgets/delayed_job_table'
require_relative 'railswatch/widgets/custom_events_table'
require_relative 'railswatch/widgets/grape_requests_table'
require_relative 'railswatch/widgets/rake_tasks_table'
require_relative 'railswatch/extensions/trace'
require_relative 'railswatch/extensions/trace_db'
require_relative 'railswatch/thread/current_request'
require_relative 'railswatch/interface'
require_relative 'railswatch/pruner'
require 'isolate_assets'

module Railswatch
  extend Railswatch::Interface

  FORMAT = '%Y%m%dT%H%M'

  @duration = 4.hours
  @recent_requests_time_window = 60.minutes
  @recent_requests_limit = nil
  @slow_requests_time_window = 4.hours
  @slow_requests_limit = 500
  @slow_requests_threshold = 500
  @database_connection_name = nil
  @debug = false
  @enabled = true
  @mount_at = '/railswatch'
  @http_basic_authentication_enabled = false
  @http_basic_authentication_user_name = 'railswatch'
  @http_basic_authentication_password = 'password12'
  @verify_access_proc = proc { |_controller| true }
  @ignored_endpoints = Set.new([])
  @ignored_paths = Set.new([])
  @skip = false
  @home_link = '/'
  @skipable_rake_tasks = []
  @custom_data_proc = nil
  @current_user_proc = nil
  @include_rake_tasks = false
  @include_custom_events = true
  @ignore_trace_headers = ['datetimei']
  @url_options = nil
  @system_monitor_duration = 24.hours
  @retention = {
    requests: @duration,
    sidekiq: @duration,
    delayed_job: @duration,
    grape: @duration,
    rake: @duration,
    custom: @duration,
    resources: @system_monitor_duration,
    traces: @recent_requests_time_window,
    events: nil
  }
  @system_monitors = %w[
    CPULoad
    MemoryUsage
    DiskUsage
  ]
  @dashboard_charts = [
    %w[P50Card P95Card P99Card],
    'ThroughputChart',
    'ResponseTimeChart'
  ]
  @_resource_monitor = nil
  @_running_mode = nil
  @_resource_monitor_enabled = false

  class << self
    attr_accessor :duration,
                  :recent_requests_time_window,
                  :recent_requests_limit,
                  :slow_requests_time_window,
                  :slow_requests_limit,
                  :slow_requests_threshold,
                  :database_connection_name,
                  :debug,
                  :enabled,
                  :mount_at,
                  :http_basic_authentication_enabled,
                  :http_basic_authentication_user_name,
                  :http_basic_authentication_password,
                  :verify_access_proc,
                  :skip,
                  :home_link,
                  :skipable_rake_tasks,
                  :custom_data_proc,
                  :current_user_proc,
                  :include_rake_tasks,
                  :include_custom_events,
                  :ignore_trace_headers,
                  :url_options,
                  :system_monitor_duration,
                  :retention,
                  :system_monitors,
                  :dashboard_charts,
                  :_resource_monitor,
                  :_running_mode,
                  :_resource_monitor_enabled

    attr_reader :ignored_endpoints, :ignored_paths

    def ignored_endpoints=(endpoints)
      @ignored_endpoints = Set.new(endpoints)
    end

    def ignored_paths=(paths)
      @ignored_paths = Set.new(paths)
    end
  end

  def self.setup
    yield(self)
  end

  def self.prune!
    Railswatch::Pruner.call
  end

  def self.measure(...)
    Railswatch::Gems::CustomExtension.measure(...)
  end

  def self.log(message)
    return unless Railswatch.debug

    if ::Rails.logger
      ::Rails.logger.debug(message)
    else
      puts(message)
    end
  end
end

require 'railswatch/engine'

require_relative 'railswatch/gems/custom_ext'
