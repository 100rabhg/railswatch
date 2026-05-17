# frozen_string_literal: true

module Railswatch
  module RailswatchHelper
    NAVIGATION_ITEMS = [
      { section: :dashboard, label: 'Overview', route: :railswatch_url },
      { section: :requests, label: 'Requests', route: :railswatch_requests_url },
      { section: :recent, label: 'Recent', route: :railswatch_recent_url },
      { section: :slow, label: 'Slow', route: :railswatch_slow_url },
      { section: :crashes, label: 'Errors', route: :railswatch_crashes_url },
      {
        section: :resources,
        label: 'System',
        route: :railswatch_resources_url,
        visible: -> { Railswatch._resource_monitor_enabled }
      },
      {
        section: :sidekiq,
        label: 'Sidekiq',
        route: :railswatch_sidekiq_url,
        visible: -> { defined?(Sidekiq) }
      },
      {
        section: :delayed_job,
        label: 'Delayed Job',
        route: :railswatch_delayed_job_url,
        visible: -> { defined?(Delayed::Job) }
      },
      {
        section: :grape,
        label: 'Grape',
        route: :railswatch_grape_url,
        visible: -> { defined?(Grape) }
      },
      {
        section: :rake,
        label: 'Rake',
        route: :railswatch_rake_url,
        visible: -> { Railswatch.include_rake_tasks }
      },
      {
        section: :custom,
        label: 'Custom',
        route: :railswatch_custom_url,
        visible: -> { Railswatch.include_custom_events }
      }
    ].freeze

    PAGE_META = {
      index: {
        eyebrow: 'Performance',
        title: 'Application Command Center',
        description: lambda {
          "Live request health, latency, and throughput over the last #{human_window(Railswatch.duration)}."
        },
        badge: 'Live'
      },
      requests: {
        eyebrow: 'Analysis',
        title: 'Request Breakdown',
        description: 'Compare controllers and actions by volume, percentiles, averages, and slowest paths.'
      },
      recent: {
        eyebrow: 'Realtime',
        title: 'Recent Requests',
        description: lambda {
          "Inspect fresh traffic sampled from the last #{human_window(Railswatch.recent_requests_time_window)}."
        }
      },
      slow: {
        eyebrow: 'Latency',
        title: 'Slow Requests',
        description: lambda {
          "Focus on requests above #{Railswatch.slow_requests_threshold} ms " \
            'and inspect traces before they age out.'
        }
      },
      crashes: {
        eyebrow: 'Reliability',
        title: '500 Error Timeline',
        description: 'Review failures, backtraces, and the request context that led to them.'
      },
      resources: {
        eyebrow: 'Infrastructure',
        title: 'System Resources',
        description: lambda {
          'Watch CPU, memory, and disk behavior across the last ' \
            "#{human_window(Railswatch.system_monitor_duration)}."
        }
      },
      sidekiq: {
        eyebrow: 'Async Jobs',
        title: 'Sidekiq Workload',
        description: 'Track job throughput, worker runtime, and recent executions.'
      },
      delayed_job: {
        eyebrow: 'Async Jobs',
        title: 'Delayed Job Workload',
        description: 'Monitor queue throughput, execution time, and recent jobs.'
      },
      grape: {
        eyebrow: 'API',
        title: 'Grape Endpoints',
        description: 'Keep an eye on API traffic volume and recent endpoint activity.'
      },
      rake: {
        eyebrow: 'Automation',
        title: 'Rake Tasks',
        description: 'Surface task runtime and throughput for your scheduled or manual jobs.'
      },
      custom: {
        eyebrow: 'Business Events',
        title: 'Custom Measurements',
        description: 'Explore custom event timing and throughput captured with Railswatch.measure.'
      },
      default: {
        eyebrow: 'Monitoring',
        title: 'Railswatch',
        description: 'Observe the health of your Rails application.'
      }
    }.freeze

    def navigation_items
      NAVIGATION_ITEMS.filter_map do |item|
        next unless navigation_item_visible?(item)

        item.slice(:section, :label).merge(path: railswatch.public_send(item[:route]))
      end
    end

    def page_meta(section = action_name.to_sym)
      resolve_page_meta(PAGE_META[section.to_sym] || PAGE_META[:default])
    end

    def round_it(value, limit = 1)
      return nil unless value
      return value if value.is_a?(Integer)

      value.nan? ? nil : value.round(limit)
    end

    def duration_alert_class(duration_str) # rubocop:disable Metrics/MethodLength
      if duration_str.to_s =~ /(\d+.?\d+?)/
        duration = ::Regexp.last_match(1).to_f
        if duration >= 500
          'has-background-danger has-text-white-bis'
        elsif duration >= 200
          'has-background-warning has-text-black-ter'
        else
          'has-background-success has-text-white-bis'
        end
      else
        'has-background-light'
      end
    end

    def extract_duration(str)
      return str[:duration].to_s if str.is_a?(Hash) && str[:duration]

      if str =~ /Duration: (\d+.?\d+?ms)/i
        ::Regexp.last_match(1)
      else
        '-'
      end
    end

    def ms(value, limit = 1)
      result = round_it(value, limit)
      return '-' if result.nil?

      result && result != 0 ? "#{result} ms" : '< 0 ms'
    end

    def compact_number(value)
      return '0' if value.blank?

      number_to_human(value, precision: 3, strip_insignificant_zeros: true)
    end

    def percentage(value, precision = 1)
      number_to_percentage(value.to_f, precision: precision)
    end

    def health_tone(value)
      return 'neutral' if value.nil?
      return 'critical' if value >= 5
      return 'warning' if value >= 1

      'healthy'
    end

    def card_tone(label)
      case label.to_s.downcase
      when 'p50'
        'healthy'
      when 'p95'
        'warning'
      when 'p99'
        'critical'
      else
        'neutral'
      end
    end

    def card_caption(label)
      case label.to_s.downcase
      when 'p50'
        'Median request latency'
      when 'p95'
        'Tail latency for slower traffic'
      when 'p99'
        'Worst-case request experience'
      else
        'Request insight'
      end
    end

    def short_path(path, length: 55)
      content_tag :span, title: path do
        truncate(path, length: length)
      end
    end

    def link_to_path(event)
      if event[:method] == 'GET'
        link_to(short_path(event[:path]), event[:path], target: '_blank', title: short_path(event[:path]))
      else
        short_path(event[:path])
      end
    end

    def report_name(hash)
      hash.except(:on).collect do |key, value|
        next if value.blank?

        %(
        <div class="control">
          <span class="tags has-addons">
            <span class="tag">#{key}</span>
            <span class="tag is-info is-light">#{value}</span>
          </span>
        </div>)
      end.compact.join.html_safe
    end

    def status_tag(status) # rubocop:disable Metrics/MethodLength
      klass = case status.to_s
              when /error/, /^5/
                'tag is-danger'
              when /^4/
                'tag is-warning'
              when /^3/
                'tag is-info'
              when /^2/, /success/
                'tag is-success'
              end
      content_tag(:span, class: klass) do
        status
      end
    end

    def bot_icon(user_agent) # rubocop:disable Metrics/MethodLength
      return nil if user_agent.blank?

      browser = Browser.new(user_agent)
      if browser.bot?
        content_tag(:span, class: 'user-agent-icon', title: browser.bot&.name) do
          icon('bot')
        end
      else
        content_tag(:span, class: 'user-agent-icon user-agent-icon-user', title: 'Real User') do
          icon('user')
        end
      end
    end

    def icon(name)
      @icons ||= {}

      # https://www.iconfinder.com/iconsets/vivid
      @icons[name] ||= raw File.read(File.expand_path(File.dirname(__FILE__) + "/../../assets/images/#{name}.svg"))
    end

    def format_rm_datetime(event)
      dt = Railswatch::Reports::BaseReport.time_in_app_time_zone(event)
      I18n.l(dt, format: '%Y-%m-%d %H:%M:%S')
    end

    # Keep this method permissive because host applications may already call
    # `format_datetime` with arbitrary values in their own templates.
    def format_datetime(event = nil, **)
      return event.to_s unless event.respond_to?(:in_time_zone) || event.respond_to?(:utc)

      format_rm_datetime(event)
    end

    def active?(section)
      actions = {
        dashboard: 'index', crashes: 'crashes',
        requests: 'requests', resources: 'resources',
        recent: 'recent', slow: 'slow',
        sidekiq: 'sidekiq', delayed_job: 'delayed_job',
        grape: 'grape', rake: 'rake', custom: 'custom'
      }
      return false unless controller_name == 'railswatch'

      'is-active' if action_name == actions[section]
    end

    private

    def navigation_item_visible?(item)
      visibility_rule = item[:visible]
      visibility_rule.nil? || instance_exec(&visibility_rule)
    end

    def resolve_page_meta(meta)
      meta.transform_values do |value|
        value.respond_to?(:call) ? instance_exec(&value) : value
      end
    end

    def human_window(duration)
      seconds = duration.to_i
      return '0 minutes' if seconds <= 0

      parts = []
      { day: 1.day, hour: 1.hour, minute: 1.minute }.each do |name, unit|
        next if seconds < unit

        value, seconds = seconds.divmod(unit)
        parts << "#{value} #{name}#{'s' if value != 1}"
      end

      parts.first(2).join(' ')
    end
  end
end
