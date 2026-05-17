# frozen_string_literal: true

require 'test_helper'

class GrapeRecordTest < ActiveSupport::TestCase
  setup do
    reset_storage
  end

  test 'storing' do
    assert_nothing_raised do
      dummy_grape_record.save!
    end
  end

  test 'record payload and hash' do
    record = dummy_grape_record(status: 200, format: 'json', method: 'GET', path: '/api/users', request_id: '1122')
    record.endpoint_render_grape = 0.0001797
    record.endpoint_run_grape = 0.000763125
    record.format_response_grape = 7.1058e-05
    record.save!

    stored = Railswatch::Models::GrapeRecord.find_by!(request_id: '1122')
    assert_equal 'json', stored.format
    assert_equal '/api/users', stored.path
    assert_equal 'GET', stored.method
    assert_equal '200', stored.status
    assert_equal '1122', stored.request_id
    assert_equal 0.0001797, stored.value['endpoint_render.grape']
    assert_equal 0.000763125, stored.value['endpoint_run.grape']
    assert_equal 7.1058e-05, stored.value['format_response.grape']
  end
end
