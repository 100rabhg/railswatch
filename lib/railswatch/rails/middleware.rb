# frozen_string_literal: true

module Railswatch
  module Rails
    class MiddlewareTraceStorerAndCleanup
      def initialize(app)
        @app = app
      end

      def call(env)
        dup.call!(env)
      end

      def call!(env)
        Railswatch.skip = true if monitoring_path?(env)

        @status, @headers, @response = @app.call(env)
        save_trace_record unless Railswatch.skip

        CurrentRequest.cleanup

        [@status, @headers, @response]
      end

      private

      def monitoring_path?(env)
        /#{Railswatch.mount_at}/.match?(env['PATH_INFO'])
      end

      def save_trace_record
        Railswatch::Models::TraceRecord.new(
          request_id: CurrentRequest.current.request_id,
          value: CurrentRequest.current.tracings,
          occurred_at: Railswatch::Utils.time
        ).save
      end
    end

    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        dup.call!(env)
      end

      def call!(env)
        @status, @headers, @response = @app.call(env)
        save_request_record(env)

        [@status, @headers, @response]
      end

      private

      def save_request_record(env)
        data = CurrentRequest.current.data
        return if Railswatch.skip || CurrentRequest.current.ignore.include?(:monitoring) || data.blank?

        record = Railswatch::Models::RequestRecord.new(**data, request_id: CurrentRequest.current.request_id)
        normalize_status!(record)
        add_http_referer!(record, env)
        add_custom_data!(record, env)
        add_request_context!(record, env)
        record.save
      end

      def normalize_status!(record)
        record.status ||= @status
        record.status = record.status.to_s if record.status.present?
      end

      def add_http_referer!(record, env)
        record.http_referer = env['HTTP_REFERER'] if record.status == '404'
      end

      def add_custom_data!(record, env)
        return unless Railswatch.custom_data_proc

        record.custom_data = Railswatch.custom_data_proc.call(env)
      end

      def add_request_context!(record, env)
        record.request_context = {
          ip: request_ip(env),
          user_agent: env['HTTP_USER_AGENT'],
          params: filtered_request_params(env).presence,
          user: current_user_info(env)
        }.compact
      rescue StandardError
        nil
      end

      def request_ip(env)
        forwarded = env['HTTP_X_FORWARDED_FOR']
        forwarded ? forwarded.split(',').first&.strip : env['REMOTE_ADDR']
      end

      def filtered_request_params(env)
        params = ActionDispatch::Request.new(env).params.to_h
        Railswatch::Utils.filter_params(params)
      rescue StandardError
        {}
      end

      def current_user_info(env)
        return nil unless Railswatch.current_user_proc

        Railswatch.current_user_proc.call(env)&.presence
      rescue StandardError
        nil
      end
    end
  end
end
