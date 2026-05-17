# frozen_string_literal: true

module Railswatch
  module Extensions
    module View
      # in env
      # this works if config.log_level = :info
      def info
        CurrentRequest.current.trace({ group: :view, message: yield })
        super
      end
    end
  end
end
