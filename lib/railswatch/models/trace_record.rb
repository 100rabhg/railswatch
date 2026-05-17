# frozen_string_literal: true

module Railswatch
  module Models
    class TraceRecord < BaseRecord
      self.table_name = 'railswatch_trace_records'

      serialize :entries, coder: JSON

      validates :request_id, presence: true

      def value
        entries || []
      end

      def value=(val)
        self.entries = val
      end
    end
  end
end
