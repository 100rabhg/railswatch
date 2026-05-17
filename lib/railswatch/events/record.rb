# frozen_string_literal: true

module Railswatch
  module Events
    class Record
      attr_reader :record

      DEFAULT_COLOR = '#FF00FF'
      DEFAULT_LABEL_COLOR = '#FF00FF'
      DEFAULT_LABEL_ORIENTATION = 'horizontal'

      class << self
        def create(name:, datetimei: Time.now.to_i, options: {})
          model = Railswatch::Models::EventRecord.create!(
            name: name,
            options: options,
            occurred_at: Railswatch::Utils.from_datetimei(datetimei.to_i)
          )
          new(model)
        end

        def all
          Railswatch::Models::EventRecord.order(:occurred_at).map { |record| new(record) }
        end
      end

      def initialize(record)
        @record = record
      end

      delegate :name, to: :record

      def datetimei
        record.occurred_at.to_i
      end

      def options
        (record.options || {}).deep_stringify_keys
      end

      def value
        {
          name: name,
          datetime: record.occurred_at,
          datetimei: datetimei,
          options: options
        }
      end

      def to_annotation
        {
          x: datetimei * 1000,
          borderColor: options['borderColor'] || DEFAULT_COLOR,
          label: {
            borderColor: options.dig('label', 'borderColor') || DEFAULT_LABEL_COLOR,
            orientation: options.dig('label', 'orientation') || DEFAULT_LABEL_ORIENTATION,
            text: options.dig('label', 'text') || name
          }
        }
      end
    end
  end
end
