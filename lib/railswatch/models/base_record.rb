# frozen_string_literal: true

require 'time'

module Railswatch
  module Models
    class BaseRecord < ApplicationRecord
      self.abstract_class = true

      before_validation :normalize_occurred_at!

      def datetime
        occurred_at&.utc&.strftime(Railswatch::FORMAT)
      end

      def datetime=(value)
        @legacy_datetime = value
      end

      def datetimei
        occurred_at&.to_i
      end

      def datetimei=(value)
        @legacy_datetimei = value&.to_i
      end

      def value
        payload_hash
      end

      def duration
        value['duration']
      end

      private

      def payload_hash
        {}
      end

      def ms(value)
        "#{value.to_f.round(1)} ms" if value
      end

      def normalize_occurred_at!
        self.occurred_at ||= if @legacy_datetimei.present?
                               Time.at(@legacy_datetimei, in: '+00:00')
                             elsif @legacy_datetime.present?
                               Time.strptime(@legacy_datetime, Railswatch::FORMAT).utc
                             else
                               Railswatch::Utils.time
                             end
      rescue ArgumentError
        self.occurred_at ||= Railswatch::Utils.time
      end
    end
  end
end
