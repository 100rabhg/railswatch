# frozen_string_literal: true

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require 'simplecov'
require 'minitest/autorun'
require 'fileutils'

SimpleCov.start do
  add_filter 'test/dummy'
end

require_relative '../test/dummy/config/environment'
class RailswatchTestConnection < ActiveRecord::Base
  self.abstract_class = true
end

ActiveRecord::Migrator.migrations_paths = [File.expand_path('../test/dummy/db/migrate', __dir__)]

def storage_connection_name(connection_name)
  return nil if connection_name.blank?

  target = connection_name.to_s
  configs = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env)
  return target if configs.any? { |config| config.name == target }

  "#{Rails.env}_#{target}"
end

require 'rails/test_help'

Minitest.backtrace_filter = Minitest::BacktraceFilter.new

def performance_models # rubocop:disable Metrics/MethodLength
  [
    Railswatch::Models::RequestRecord,
    Railswatch::Models::TraceRecord,
    Railswatch::Models::SidekiqRecord,
    Railswatch::Models::DelayedJobRecord,
    Railswatch::Models::GrapeRecord,
    Railswatch::Models::RakeRecord,
    Railswatch::Models::CustomRecord,
    Railswatch::Models::ResourceRecord,
    Railswatch::Models::EventRecord
  ]
end

def reset_storage
  previous_connection = Railswatch.database_connection_name

  [nil, :railswatch].each do |connection_name|
    next if connection_name && !storage_database_ready?(connection_name)

    Railswatch.database_connection_name = connection_name
    Railswatch::Models::ApplicationRecord.reset_storage_connection!
    performance_models.each(&:delete_all)
  end
ensure
  Railswatch.database_connection_name = previous_connection
  Railswatch::Models::ApplicationRecord.reset_storage_connection!
end

def storage_database_ready?(connection_name)
  resolved_name = storage_connection_name(connection_name)
  return false unless resolved_name

  RailswatchTestConnection.establish_connection(resolved_name.to_sym)
  RailswatchTestConnection.connection.data_source_exists?(:railswatch_request_records)
rescue ActiveRecord::NoDatabaseError, ActiveRecord::ConnectionNotEstablished
  false
end

module ActiveSupport
  class TestCase
    setup do
      reset_storage
    end
  end
end

module ActionDispatch
  class IntegrationTest
    setup do
      reset_storage
    end
  end
end

def dummy_event(time: Railswatch::Utils.time, controller: 'Home', action: 'index', status: 200, path: '/', method: 'GET', # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists, Layout/LineLength
                request_id: SecureRandom.hex(16))
  Railswatch::Models::RequestRecord.new(
    controller: controller,
    action: action,
    format: 'html',
    status: status.to_s,
    datetime: time.strftime(Railswatch::FORMAT),
    datetimei: time.to_i,
    method: method,
    path: path,
    view_runtime: rand(100.0),
    db_runtime: rand(100.0),
    duration: 100 + rand(100.0),
    request_id: request_id
  )
end

def dummy_sidekiq_event(worker: 'Worker', queue: 'default', jid: "jxzet-#{Railswatch::Utils.time.to_i}", # rubocop:disable Metrics/ParameterLists
                        datetimei: Railswatch::Utils.time.to_i, enqueued_ati: Railswatch::Utils.time.to_i,
                        start_timei: Railswatch::Utils.time.to_i, duration: rand(60), status: 'success')
  Railswatch::Models::SidekiqRecord.new(
    queue: queue, worker: worker, jid: jid, datetimei: datetimei,
    enqueued_ati: enqueued_ati,
    datetime: Railswatch::Utils.from_datetimei(datetimei).strftime(Railswatch::FORMAT),
    start_timei: start_timei,
    duration: duration,
    status: status
  )
end

def dummy_grape_record(datetimei: Railswatch::Utils.time.to_i, status: 200, format: 'json', # rubocop:disable Metrics/ParameterLists
                       method: 'GET', path: '/api/users', request_id: SecureRandom.hex(16))
  Railswatch::Models::GrapeRecord.new(
    path: path, method: method, format: format, status: status.to_s, datetimei: datetimei,
    datetime: Railswatch::Utils.from_datetimei(datetimei).strftime(Railswatch::FORMAT),
    endpoint_render_grape: rand(10),
    endpoint_run_grape: rand(10),
    format_response_grape: rand(10),
    request_id: request_id
  )
end

def dummy_rake_record(datetimei: Railswatch::Utils.time.to_i, status: 'success',
                      task: "x111111111#{rand(10_000_000)}")
  Railswatch::Models::RakeRecord.new(
    task: task,
    datetime: Railswatch::Utils.from_datetimei(datetimei).strftime(Railswatch::FORMAT),
    datetimei: datetimei,
    status: status,
    duration: 100
  )
end

def dummy_delayed_job_record(datetimei: Railswatch::Utils.time.to_i, status: 'success',
                             jid: "x111111111#{rand(10_000_000)}")
  Railswatch::Models::DelayedJobRecord.new(
    jid: jid,
    datetime: Railswatch::Utils.from_datetimei(datetimei).strftime(Railswatch::FORMAT),
    datetimei: datetimei,
    source_type: 'instance_method',
    class_name: 'User',
    method_name: 'hell_world',
    status: status,
    duration: 100
  )
end

def setup_db(event = dummy_event)
  event.save!
end

def setup_sidekiq_db(event = dummy_sidekiq_event)
  event.save!
end

def setup_rake_db(event = dummy_rake_record)
  event.save!
end

def setup_delayed_job_db(event = dummy_delayed_job_record)
  event.save!
end

def setup_grape_db(event = dummy_grape_record)
  event.save!
end
