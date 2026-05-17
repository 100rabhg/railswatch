# frozen_string_literal: true

module Railswatch
  module Extensions
    module Db
      # in env
      # this works if config.log_level = :debug
      def sql(event)
        sql_text = event.payload[:sql].to_s
        return super if sql_text.match?(/\brailswatch_/i)

        CurrentRequest.current.trace({
                                       group: :db,
                                       duration: event.duration.round(2),
                                       sql: sql_text
                                     })
        super
      end
    end
  end
end
