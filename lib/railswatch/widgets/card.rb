# frozen_string_literal: true

module Railswatch
  module Widgets
    class Card < Base
      def label
        raise NotImplementedError
      end

      def value
        raise NotImplementedError
      end

      def to_partial_path
        'railswatch/railswatch/card'
      end
    end
  end
end
