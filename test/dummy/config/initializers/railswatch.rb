# frozen_string_literal: true

if defined?(Railswatch)
  Railswatch.setup do |config|
    config.database_connection_name = nil
    config.duration = 6.hours

    config.debug = true
    config.enabled = true

    config.recent_requests_time_window = 60.minutes
    config.recent_requests_limit = nil

    # config.mount_at = '/admin/monitoring'

    # protect your Performance Dashboard with HTTP BASIC password
    config.http_basic_authentication_enabled = false
    config.http_basic_authentication_user_name = 'railswatch'
    config.http_basic_authentication_password = 'password12'

    # if you need an additional rules to check user permissions
    # config.verify_access_proc = proc { |controller| true }
    # for example when you have `current_user`
    config.verify_access_proc = proc { |_controller| true }

    # store custom data for the request
    config.custom_data_proc = proc do |env|
      request = Rack::Request.new(env)
      {
        email: request.env['warden'].user&.email, # if you are using Devise for example
        user_agent: request.env['HTTP_USER_AGENT']
      }
    end

    # config home button link
    config.home_link = '/'

    config.include_rake_tasks = true
    config.include_custom_events = true

    # If enabled, the system monitor will be displayed on the dashboard
    # to enabled add required gems (see README)
    config.system_monitor_duration = 24.hours

    config.retention = {
      requests: config.duration,
      sidekiq: config.duration,
      delayed_job: config.duration,
      grape: config.duration,
      rake: config.duration,
      custom: config.duration,
      traces: config.recent_requests_time_window,
      resources: config.system_monitor_duration,
      events: nil
    }
  end
end
