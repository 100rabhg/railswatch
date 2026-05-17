# frozen_string_literal: true

require 'test_helper'

module Railswatch
  class Test1 < ActiveSupport::TestCase
    test 'duration report' do
      Railswatch.duration = 24.hours

      @datasource = Railswatch::DataSource.new(type: :requests)
      @data = Railswatch::Reports::ThroughputReport.new(@datasource.db).data

      assert_equal @data.size / 60, 24
    end
  end
end
