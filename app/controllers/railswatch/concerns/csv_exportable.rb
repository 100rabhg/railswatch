# frozen_string_literal: true

require 'csv'
module Railswatch
  module Concerns
    module CsvExportable
      extend ActiveSupport::Concern

      def export_to_csv(filename, data)
        send_data generate_csv(data),
                  filename: "#{filename}_#{Time.zone.today}.csv",
                  type: 'text/csv',
                  disposition: 'attachment'
      end

      private

      def generate_csv(data)
        CSV.generate(headers: true) do |csv|
          next if data.blank?

          headers = data.first.keys
          csv << headers.map(&:to_s)
          data.each do |entry|
            csv << headers.map { |header| entry[header].to_s }
          end
        end
      end
    end
  end
end
