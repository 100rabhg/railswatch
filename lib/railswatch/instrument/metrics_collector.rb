# frozen_string_literal: true

module Railswatch
  module Instrument
    class MetricsCollector
      # payload
      # {
      #   controller: "PostsController",
      #   action: "index",
      #   params: {"action" => "index", "controller" => "posts"},
      #   headers: #<ActionDispatch::Http::Headers:0x0055a67a519b88>,
      #   format: :html,
      #   method: "GET",
      #   path: "/posts",
      #   status: 200,
      #   view_runtime: 46.848,
      #   db_runtime: 0.157
      # }

      def call(event_name, started, finished, event_id, payload)
        return if Railswatch.skip
        return if CurrentRequest.current.data

        return if ignored_event?(payload)

        CurrentRequest.current.data = build_record(
          event_name: event_name,
          started: started,
          finished: finished,
          event_id: event_id,
          payload: payload
        )
      end

      private

      def ignored_event?(payload)
        return true if payload[:controller].blank?

        endpoint = "#{payload[:controller]}##{payload[:action]}"
        Railswatch.ignored_endpoints.include?(endpoint) ||
          Railswatch.ignored_paths.any? { |path| payload[:path].start_with?(path) }
      end

      def build_record(event_name:, started:, finished:, event_id:, payload:) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        event = notification_event(event_name, started, finished, event_id, payload)
        finished_at = finished.is_a?(Time) ? finished.utc : Time.at(finished).utc
        {
          controller: payload[:controller],
          action: payload[:action],
          format: payload[:format],
          status: payload[:status],
          datetime: finished_at.strftime(Railswatch::FORMAT),
          datetimei: finished_at.to_i,
          method: payload[:method],
          path: payload[:path],
          view_runtime: payload[:view_runtime],
          db_runtime: payload[:db_runtime],
          duration: event.duration,
          exception: payload[:exception],
          exception_object: payload[:exception_object]
        }
      end

      def notification_event(event_name, started, finished, event_id, payload)
        ActiveSupport::Notifications::Event.new(event_name, started, finished, event_id, payload)
      end
    end
  end
end
