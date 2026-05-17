# frozen_string_literal: true

module Railswatch
  module Reports
    class CrashReport < BaseReport
      def data
        db.order(occurred_at: :desc).map(&:record_hash)
      end
    end
  end
end
