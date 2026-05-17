# frozen_string_literal: true

module Railswatch
  class Pruner
    DEFAULT_BATCH_SIZE = 1_000

    MODEL_TYPES = {
      requests: 'RequestRecord',
      sidekiq: 'SidekiqRecord',
      delayed_job: 'DelayedJobRecord',
      grape: 'GrapeRecord',
      rake: 'RakeRecord',
      custom: 'CustomRecord',
      resources: 'ResourceRecord',
      traces: 'TraceRecord',
      events: 'EventRecord'
    }.freeze

    def self.call(batch_size: DEFAULT_BATCH_SIZE)
      MODEL_TYPES.each_with_object({}) do |(type, class_name), results|
        deleted = deleted_records(type, class_name, batch_size)
        results[type] = deleted unless deleted.nil?
      end
    end

    def self.deleted_records(type, class_name, batch_size)
      retention = Railswatch.retention[type]
      return if retention.nil?

      model = Railswatch::Models.const_get(class_name)
      threshold = Railswatch::Utils.kind_of_now - retention

      delete_in_batches(model, threshold, batch_size)
    end

    def self.delete_in_batches(model, threshold, batch_size)
      deleted = 0

      loop do
        ids = model.where('occurred_at < ?', threshold).limit(batch_size).pluck(:id)
        break deleted if ids.empty?

        deleted += model.where(id: ids).delete_all
      end
    end
  end
end
