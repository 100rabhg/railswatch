# frozen_string_literal: true

module Railswatch
  module Reports
    class ResourcesReport < BaseReport
      Server = Struct.new(:report, :key) do
        def name
          key.split('///').join(', ')
        end

        def charts
          Railswatch.system_monitors.map do |class_name|
            Widgets.const_get(class_name).new(self)
          end
        end
      end

      def servers
        data.keys.map { |key| Server.new(self, key) }
      end

      def extract_signal(&block)
        data.transform_values do |records|
          prepare_report(records.to_h do |entry|
                           [entry[:datetimei] * 1000, block.call(entry)]
                         end)
        end
      end

      private

      def data
        @data ||= db.order(:occurred_at).map(&:record_hash)
                    .group_by { |entry| "#{entry[:server]}///#{entry[:context]}///#{entry[:role]}" }
      end

      def prepare_report(input)
        nullify_data(input, Railswatch.system_monitor_duration)
      end
    end
  end
end
