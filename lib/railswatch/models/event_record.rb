# frozen_string_literal: true

module Railswatch
  module Models
    class EventRecord < BaseRecord
      self.table_name = 'railswatch_event_records'

      serialize :options, coder: JSON
    end
  end
end
