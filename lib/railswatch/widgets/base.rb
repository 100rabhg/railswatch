# frozen_string_literal: true

module Railswatch
  module Widgets
    class Base
      attr_reader :datasource

      def initialize(datasource)
        @datasource = datasource
      end

      def to_partial_path
        raise NotImplementedError
      end
    end
  end
end
