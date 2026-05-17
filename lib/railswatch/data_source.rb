# frozen_string_literal: true

require 'forwardable'

module Railswatch
  class DataSource
    class RelationWrapper
      extend Forwardable

      def_delegators :@relation,
                     :where, :order, :limit, :pluck, :map, :group, :count,
                     :average, :maximum, :all, :to_a, :find_by, :each,
                     :klass

      def initialize(relation)
        @relation = relation
      end

      def data
        @relation.to_a
      end
    end

    KLASSES = {
      requests: Railswatch::Models::RequestRecord,
      sidekiq: Railswatch::Models::SidekiqRecord,
      delayed_job: Railswatch::Models::DelayedJobRecord,
      grape: Railswatch::Models::GrapeRecord,
      rake: Railswatch::Models::RakeRecord,
      custom: Railswatch::Models::CustomRecord,
      resources: Railswatch::Models::ResourceRecord
    }.freeze

    attr_reader :query, :klass, :type, :days

    def initialize(type:, query: {}, days: Railswatch::Utils.days(Railswatch.duration))
      @type = type
      @klass = KLASSES.fetch(type)
      @query = query
      @days = days
    end

    def db
      scope = klass.all
      scope = apply_time_window(scope)
      RelationWrapper.new(apply_filters(scope))
    end

    def default?
      query.empty?
    end

    private

    def apply_time_window(scope)
      return scope.where(occurred_at: query[:on].all_day) if query[:on].present?

      now = Railswatch::Utils.kind_of_now
      scope.where(occurred_at: (now - days.days)..now)
    end

    def apply_filters(scope) # rubocop:disable Metrics/MethodLength
      case type
      when :requests
        apply_request_filters(scope)
      when :resources
        apply_resource_filters(scope)
      when :sidekiq
        apply_sidekiq_filters(scope)
      when :delayed_job, :grape, :rake, :custom
        apply_status_filter(scope)
      else
        scope
      end
    end

    def apply_request_filters(scope) # rubocop:disable Metrics/AbcSize
      scope = scope.where(controller: query[:controller]) if query[:controller].present?
      scope = scope.where(action: query[:action]) if query[:action].present?
      scope = scope.where(format: query[:format]) if query[:format].present?
      scope = scope.where(status: query[:status].to_s) if query[:status].present?
      scope = scope.where(http_method: query[:method]) if query[:method].present?
      scope = scope.where(path: query[:path]) if query[:path].present?
      scope
    end

    def apply_resource_filters(scope) # rubocop:disable Metrics/AbcSize
      scope = scope.where(server: query[:server]) if query[:server].present?
      scope = scope.where(context: query[:context]) if query[:context].present?
      scope = scope.where(role: query[:role]) if query[:role].present?
      scope
    end

    def apply_sidekiq_filters(scope) # rubocop:disable Metrics/AbcSize
      scope = scope.where(queue: query[:queue]) if query[:queue].present?
      scope = scope.where(worker: query[:worker]) if query[:worker].present?
      scope = scope.where(status: query[:status].to_s) if query[:status].present?
      scope
    end

    def apply_status_filter(scope)
      scope = scope.where(status: query[:status].to_s) if query[:status].present?
      scope
    end
  end
end
