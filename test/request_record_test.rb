# frozen_string_literal: true

require 'test_helper'

class RequestRecordTest < ActiveSupport::TestCase
  setup do
    reset_storage
  end

  test 'storing' do
    assert_nothing_raised do
      dummy_event.save!
    end
  end

  test 'record payload and hash' do
    record = dummy_event(
      controller: 'HomeController',
      action: 'index',
      status: 200,
      request_id: '1fb7f6c4d874e10644e1259ac44b514e'
    )
    record.exception = 'ZeroDivisionError divided by 0'
    record.backtrace = %w[a b c]
    record.save!

    stored = Railswatch::Models::RequestRecord.find_by!(request_id: record.request_id)
    assert_equal 'HomeController', stored.controller
    assert_equal '200', stored.status
    assert_equal 'ZeroDivisionError divided by 0', stored.value['exception']
    assert_equal %w[a b c], stored.value['backtrace']
    assert_equal 3, stored.value['backtrace'].size
    assert_equal record.request_id, stored.request_id
    assert_equal record.record_hash[:path], stored.record_hash[:path]
  end
end
