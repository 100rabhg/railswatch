# frozen_string_literal: true

module Railswatch
  module Interface
    def create_event(name:, datetime: Railswatch::Utils.time, options: {})
      Railswatch::Events::Record.create(name: name, datetimei: datetime.to_i, options: options)
    end
  end
end
