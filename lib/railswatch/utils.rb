# frozen_string_literal: true

module Railswatch
  class Utils
    DEFAULT_TIME_OFFSET = 1.minute

    def self.time
      Time.now.utc
    end

    def self.kind_of_now
      time + DEFAULT_TIME_OFFSET
    end

    def self.from_datetimei(datetimei)
      Time.at(datetimei, in: '+00:00')
    end

    def self.days(duration = Railswatch.duration)
      (duration / 1.day) + 1
    end

    def self.median(array)
      sorted = array.sort
      size = sorted.size
      center = size / 2

      if size.zero?
        nil
      elsif size.even?
        (sorted[center - 1] + sorted[center]) / 2.0
      else
        sorted[center]
      end
    end

    def self.percentile(values, percentile)
      return nil if values.empty?

      sorted = values.sort
      rank = (percentile.to_f / 100) * (sorted.size - 1)

      lower = sorted[rank.floor]
      upper = sorted[rank.ceil]
      lower + ((upper - lower) * (rank - rank.floor))
    end

    def self.filter_params(params)
      return {} if params.blank?
      return {} unless defined?(::Rails) && ::Rails.application

      filter = ActiveSupport::ParameterFilter.new(::Rails.application.config.filter_parameters)
      filter.filter(params.to_h)
    rescue StandardError
      {}
    end
  end
end
