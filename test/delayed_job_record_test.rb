# frozen_string_literal: true

require 'test_helper'

class DelayedJobRecordTest < ActiveSupport::TestCase
  setup do
    reset_storage
  end

  test 'base works' do
    assert_nothing_raised do
      User.create.say_hello
      Delayed::Worker.new.work_off
    end
  end

  test 'storage' do
    assert_nothing_raised do
      dummy_delayed_job_record.save!
    end
  end

  test 'record payload and hash' do
    record = dummy_delayed_job_record(jid: '24')
    record.source_type = 'class_method'
    record.class_name = 'User'
    record.method_name = 'xxx'
    record.duration = 0.000221818
    record.save!

    stored = Railswatch::Models::DelayedJobRecord.find_by!(jid: '24')
    assert_equal '24', stored.jid
    assert_equal 'class_method', stored.source_type
    assert_equal 'User', stored.class_name
    assert_equal 'xxx', stored.method_name
    assert_equal 0.000221818, stored.value['duration']
  end
end
