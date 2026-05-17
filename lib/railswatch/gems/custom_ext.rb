# frozen_string_literal: true

module Railswatch
  module Gems
    module CustomExtension
      module_function

      def measure(tag_name, namespace_name = nil, &)
        return yield unless Railswatch.enabled && Railswatch.include_custom_events

        now = Railswatch::Utils.time
        status = 'success'
        execute_with_status(&)
      rescue Exception => e # rubocop:disable Lint/RescueException
        status = 'error'
        raise(e)
      ensure
        save_custom_record(tag_name, namespace_name, status, now)
        CurrentRequest.cleanup
      end

      def execute_with_status
        yield
      end

      def save_custom_record(tag_name, namespace_name, status, now)
        Railswatch::Models::CustomRecord.new(
          tag_name: tag_name,
          namespace_name: namespace_name,
          status: status,
          duration: (Railswatch::Utils.time - now) * 1000,
          datetime: now.strftime(Railswatch::FORMAT),
          datetimei: now.to_i
        ).save
      end
    end
  end
end
