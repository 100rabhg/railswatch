# frozen_string_literal: true

require 'test_helper'

class DatabaseStorageTest < ActiveSupport::TestCase
  setup do
    reset_storage
  end

  test 'writes to dedicated storage database when configured' do
    skip 'Dedicated database routing requires isolated migration setup in this test environment'
    Railswatch.database_connection_name = :railswatch
    Railswatch::Models::ApplicationRecord.reset_storage_connection!

    setup_db(dummy_event(request_id: 'separate-db'))

    Railswatch.database_connection_name = nil
    Railswatch::Models::ApplicationRecord.reset_storage_connection!
    assert_nil Railswatch::Models::RequestRecord.find_by(request_id: 'separate-db')

    Railswatch.database_connection_name = :railswatch
    Railswatch::Models::ApplicationRecord.reset_storage_connection!
    assert_equal 'separate-db', Railswatch::Models::RequestRecord.find_by(request_id: 'separate-db')&.request_id
  ensure
    Railswatch.database_connection_name = nil
    Railswatch::Models::ApplicationRecord.reset_storage_connection!
  end

  test 'prunes by retention and honors keep forever' do
    old_time = 2.days.ago
    fresh_time = 5.minutes.ago

    setup_db(dummy_event(time: old_time, request_id: 'old-request'))
    setup_db(dummy_event(time: fresh_time, request_id: 'fresh-request'))
    Railswatch::Events::Record.create(name: 'Deploy', datetimei: old_time.to_i)

    original_retention = Railswatch.retention
    Railswatch.retention = original_retention.merge(requests: 1.day, events: nil)
    Railswatch.prune!

    assert_nil Railswatch::Models::RequestRecord.find_by(request_id: 'old-request')
    assert_equal 'fresh-request',
                 Railswatch::Models::RequestRecord.find_by(request_id: 'fresh-request')&.request_id
    assert_equal 1, Railswatch::Models::EventRecord.count
  ensure
    Railswatch.retention = original_retention
  end
end
