# frozen_string_literal: true

if defined?(Railswatch)
  Railswatch.setup do |config|
    # Use the primary application database by default.
    # To use a dedicated database, define an additional database config and set:
    # config.database_connection_name = :railswatch
    config.database_connection_name = nil

    # All data we collect
    config.duration = 4.hours

    # Recent Requests configuration
    config.recent_requests_time_window = 60.minutes
    # config.recent_requests_limit = nil # number of recent requests

    # Slow Requests configuration
    config.slow_requests_time_window = 4.hours
    # config.slow_requests_limit = 500 # number of slow requests
    config.slow_requests_threshold = 500 # ms

    config.retention = {
      requests: config.duration,
      sidekiq: config.duration,
      delayed_job: config.duration,
      grape: config.duration,
      rake: config.duration,
      custom: config.duration,
      traces: config.recent_requests_time_window,
      resources: 24.hours,
      events: nil
    }

    config.debug = false
    config.enabled = true

    # default path where to mount gem
    config.mount_at = '/railswatch'

    # protect your Performance Dashboard with HTTP BASIC password
    config.http_basic_authentication_enabled = false
    config.http_basic_authentication_user_name = 'railswatch'
    config.http_basic_authentication_password = 'password12'

    # if you need an additional rules to check user permissions
    config.verify_access_proc = proc { |_controller| true }
    # for example when you have `current_user`
    # config.verify_access_proc = proc { |controller| controller.current_user && controller.current_user.admin? }

    # Override engine url options, necessary if hosting under a unique domain
    # config.url_options = {host: "sub.example.com"}

    # You can ignore endpoints with Rails standard notation controller#action
    # config.ignored_endpoints = ['HomeController#contact']

    # You can ignore request paths by specifying the beginning of the path.
    # For example, all routes starting with '/admin' can be ignored:
    config.ignored_paths = ['/railswatch']

    # store custom data for the request
    # config.custom_data_proc = proc do |env|
    #   request = Rack::Request.new(env)
    #   {
    #     email: request.env['warden'].user&.email, # if you are using Devise for example
    #     user_agent: request.env['HTTP_USER_AGENT']
    #   }
    # end

    # Attach current user info to each request context (stored filtered alongside IP/params).
    # The proc receives the raw Rack env and should return a plain hash.
    # Sensitive values are filtered automatically — keep this lightweight (IDs, roles, emails).
    # config.current_user_proc = proc do |env|
    #   user = env['warden']&.user   # Devise / Warden
    #   { id: user&.id, email: user&.email } if user
    # end

    # config home button link
    config.home_link = '/'
    config.skipable_rake_tasks = ['webpacker:compile']
    config.include_rake_tasks = false
    config.include_custom_events = true

    # If enabled, the system monitor will be displayed on the dashboard
    # to enabled add required gems (see README)
    # config.system_monitor_duration = 24.hours
  end
end
