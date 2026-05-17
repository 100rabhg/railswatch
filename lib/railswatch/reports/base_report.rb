# frozen_string_literal: true

module Railswatch
  module Reports
    class BaseReport
      attr_reader :db, :group, :sort, :title

      def initialize(db, group: nil, sort: nil, title: nil)
        @db = db
        @group = group
        @sort = sort
        @title = title
        set_defaults
      end

      def set_defaults; end

      def self.time_in_app_time_zone(time)
        app_time_zone = ::Rails.application.config.time_zone
        app_time_zone.present? ? time.in_time_zone(app_time_zone) : time
      end

      def nil_data(duration = Railswatch.duration)
        @nil_data_cache ||= {}
        @nil_data_cache[duration] ||= build_nil_data(duration)
      end

      def nullify_data(input, duration = Railswatch.duration)
        nil_data(duration).merge(input).sort
      end

      private

      def build_nil_data(duration)
        result = {}
        stop = Railswatch::Utils.kind_of_now.change(sec: 0, usec: 0)
        current = stop - duration

        while current <= stop
          result[current.to_i * 1000] = nil
          current += 1.minute
        end

        result
      end
    end
  end
end
