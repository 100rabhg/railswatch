# frozen_string_literal: true

require 'test_helper'

class CustomRecordTest < ActiveSupport::TestCase
  setup do
    reset_storage
  end

  test 'custom record storage' do
    result = Railswatch.measure 'x', 'y' do
      40 + 2
    end
    assert_equal 42, result
  end

  test 'custom record storage with error' do
    assert_raise(ZeroDivisionError) do
      Railswatch.measure 'x', 'y' do
        42 / 0
      end
    end
  end

  test 'custom record payload and hash' do
    record = Railswatch::Models::CustomRecord.new(
      tag_name: 'a',
      namespace_name: 'b',
      datetime: '20210418T0022',
      datetimei: 1_618_730_556,
      status: 'success',
      duration: 0.000221818
    )
    record.save!

    stored = Railswatch::Models::CustomRecord.find_by!(tag_name: 'a')
    assert_equal 'a', stored.tag_name
    assert_equal 'b', stored.namespace_name
    assert_equal 1_618_730_556, stored.datetimei
    assert_equal 'success', stored.status
    assert_equal 0.000221818, stored.value['duration']
  end
end
