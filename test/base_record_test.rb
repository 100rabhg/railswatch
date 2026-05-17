# frozen_string_literal: true

require 'test_helper'

module Railswatch
  class BaseRecord < ActiveSupport::TestCase
    test 'ms' do
      record = Railswatch::Models::BaseRecord.allocate

      assert_equal record.send(:ms, 1), '1.0 ms'
    end
  end
end
