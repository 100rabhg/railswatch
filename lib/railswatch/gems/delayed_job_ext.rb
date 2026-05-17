# frozen_string_literal: true

module Railswatch
  module Gems
    class DelayedJobExt
      class Plugin < ::Delayed::Plugin
        callbacks do |lifecycle|
          lifecycle.around(:invoke_job) do |job, *args, &block|
            now = Railswatch::Utils.time
            error = nil
            block.call(job, *args)
            status = 'success'
          rescue Exception => e # rubocop:disable Lint/RescueException
            status = 'error'
            error = e
            raise e
          ensure
            Railswatch::Gems::DelayedJobExt::Plugin.persist(job, now, status, error)
          end
        end

        def self.persist(job, now, status, error) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          meta_data = meta(job.payload_object)
          error_bt = error ? error.backtrace&.take(20)&.join("\n") : nil
          record = Railswatch::Models::DelayedJobRecord.new(
            jid: job.id,
            duration: (Railswatch::Utils.time - now) * 1000,
            datetime: now.strftime(Railswatch::FORMAT),
            datetimei: now.to_i,
            source_type: meta_data[0],
            class_name: meta_data[1],
            method_name: meta_data[2],
            status: status,
            job_args: filtered_args(job.payload_object),
            error_message: error&.message,
            error_backtrace: error_bt
          )
          record.save
          CurrentRequest.cleanup
        end

        # [source_type, class_name, method_name]
        def self.meta(payload_object) # rubocop:disable Metrics/MethodLength
          if payload_object.is_a?(::Delayed::PerformableMethod)
            if payload_object.object.is_a?(Module)
              [:class_method, payload_object.object.name, payload_object.method_name.to_s]
            else
              [:instance_method, payload_object.object.class.name, payload_object.method_name.to_s]
            end
          else
            [:instance_method, payload_object.class.name, 'perform']
          end
        rescue StandardError
          %i[unknown unknown unknown]
        end

        def self.filtered_args(payload_object)
          raw = payload_object.args if payload_object.respond_to?(:args)
          Railswatch::Utils.filter_params({ 'args' => Array.wrap(raw) })['args']
        rescue StandardError
          nil
        end
      end

      def self.init
        ::Delayed::Worker.plugins += [::Railswatch::Gems::DelayedJobExt::Plugin]
      end
    end
  end
end
