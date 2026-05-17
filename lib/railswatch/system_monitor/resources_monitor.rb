# frozen_string_literal: true

module Railswatch
  module SystemMonitor
    class ResourcesMonitor
      attr_reader :context, :role

      def initialize(context, role)
        @context = context
        @role = role
        @mutex = Mutex.new
        @thread = nil

        return unless Railswatch._resource_monitor_enabled

        start_monitoring
      end

      def start_monitoring
        @mutex.synchronize do
          return if @thread

          @thread = Thread.new { monitor_loop }
        end
      end

      def stop_monitoring
        @mutex.synchronize do
          return unless @thread

          @thread.kill
          @thread = nil
        end
      end

      def payload
        monitors.reduce({}) do |data, monitor|
          data.merge(monitor.key => monitor.measure)
        end
      end

      def monitors
        @monitors ||= Railswatch.system_monitors.map do |class_name|
          Railswatch::Widgets.const_get(class_name).new(nil)
        end
      end

      def run
        store_data(payload)
      end

      def store_data(data) # rubocop:disable Metrics/MethodLength
        now = Railswatch::Utils.kind_of_now
        now = now.change(sec: 0, usec: 0)

        Railswatch.log(resource_log_message(data))
        Railswatch::Models::ResourceRecord.new(
          server: server_id,
          context: context,
          role: role,
          datetime: now.strftime(Railswatch::FORMAT),
          datetimei: now.to_i,
          json: data
        ).save
      end

      def server_id
        @server_id ||= ENV['RAILSWATCH_SERVER_ID'] || `hostname`.strip
      end

      private

      def monitor_loop
        loop do
          run
        rescue StandardError => e
          ::Rails.logger.error "Monitor error: #{e.message}"
        ensure
          sleep 60
        end
      end

      def resource_log_message(data)
        "Server: #{server_id}, Context: #{context}, Role: #{role}, data: #{data}"
      end
    end
  end
end
