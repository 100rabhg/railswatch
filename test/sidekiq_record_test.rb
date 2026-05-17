# frozen_string_literal: true

require 'test_helper'

class SidekiqRecordTest < ActiveSupport::TestCase
  setup do
    reset_storage
  end

  test 'storing' do
    assert_nothing_raised do
      dummy_sidekiq_event.save!
    end
  end

  test 'record payload and hash' do
    record = dummy_sidekiq_event(worker: 'SimpleWorker', queue: 'default', jid: '7d48fbf20976c224510dbc60')
    record.message = 'hello'
    record.save!

    stored = Railswatch::Models::SidekiqRecord.find_by!(jid: '7d48fbf20976c224510dbc60')
    assert_equal 'default', stored.queue
    assert_equal 'SimpleWorker', stored.worker
    assert_equal 'hello', stored.value['message']
    assert_equal '7d48fbf20976c224510dbc60', stored.jid
    assert_equal stored.duration_ms, stored.value['duration']
  end
end
