# frozen_string_literal: true

require 'test_helper'

class RakeRecordTest < ActiveSupport::TestCase
  setup do
    reset_storage
  end

  test 'rake_record' do
    record = Railswatch::Models::RakeRecord.new(
      task: ['task3'],
      datetime: '20210416T1254',
      datetimei: 1_618_602_843,
      status: 'error',
      duration: 0.00012442
    )
    record.save!

    stored = Railswatch::Models::RakeRecord.find_by!(status: 'error')
    assert_equal ['task3'], stored.task
    assert_equal 1_618_602_843, stored.datetimei
    assert_equal 'error', stored.status
    assert_equal 0.00012442, stored.value['duration']
  end
end
