# frozen_string_literal: true

require 'test_helper'

class UtilsTest < ActiveSupport::TestCase
  test 'median' do
    assert_equal Railswatch::Utils.median([1, 2, 3]), 2
    assert_equal Railswatch::Utils.median([1, 2, 3, 4]), 2.5
  end

  test 'percentile' do
    assert_equal Railswatch::Utils.percentile([1, 2, 3], 50).round(2), 2
    assert_equal Railswatch::Utils.percentile([1, 2, 3, 4], 95).round(2), 3.85
    assert_equal Railswatch::Utils.percentile([1, 2, 3, 4], 99).round(2), 3.97
  end
end
