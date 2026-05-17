# frozen_string_literal: true

module Railswatch
  module Gems
    class RakeExt
      class << self
        def init # rubocop:disable Metrics/MethodLength
          ::Rake::Task.class_eval do
            next if method_defined?(:invoke_with_railswatch)

            def invoke_with_railswatch(*args)
              now = Railswatch::Utils.time
              status = 'success'
              invoke_without_new_railswatch(*args)
            rescue Exception => e # rubocop:disable Lint/RescueException
              status = 'error'
              raise(e)
            ensure
              Railswatch::Gems::RakeExt.store_invocation(self, args, now, status)
            end

            alias_method :invoke_without_new_railswatch, :invoke
            alias_method :invoke, :invoke_with_railswatch

            def invoke(*args) # rubocop:disable Lint/DuplicateMethods
              invoke_with_railswatch(*args)
            end
          end
        end

        def find_task_name(*args)
          (ARGV + args).compact
        end

        def store_invocation(task, args, started_at, status)
          return if Railswatch.skipable_rake_tasks.include?(task.name)
          return unless monitoring_storage_available?

          build_rake_record(task, args, started_at, status).save
        ensure
          CurrentRequest.cleanup
        end

        def resolved_task_name(task, args)
          task_info = find_task_name(*args)
          task_info.empty? ? [task.name] : task_info
        end

        def monitoring_storage_available?
          Railswatch::Models::RakeRecord.connection.data_source_exists?(
            Railswatch::Models::RakeRecord.table_name
          )
        rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
          false
        end

        def build_rake_record(task, args, started_at, status)
          Railswatch::Models::RakeRecord.new(
            task: resolved_task_name(task, args),
            datetime: started_at.strftime(Railswatch::FORMAT),
            datetimei: started_at.to_i,
            duration: (Railswatch::Utils.time - started_at) * 1000,
            status: status
          )
        end
      end
    end
  end
end
