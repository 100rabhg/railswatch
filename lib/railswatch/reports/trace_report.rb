# frozen_string_literal: true

module Railswatch
  module Reports
    class TraceReport
      attr_reader :request_id

      def initialize(request_id:)
        @request_id = request_id
      end

      def data
        Railswatch::Models::TraceRecord.find_by(request_id: request_id)&.value || []
      end
    end
  end
end
