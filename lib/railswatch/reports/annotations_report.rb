# frozen_string_literal: true

module Railswatch
  module Reports
    class AnnotationsReport
      def data
        {
          xaxis: Railswatch::Events::Record.all.map(&:to_annotation)
        }
      end
    end
  end
end
