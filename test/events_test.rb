# frozen_string_literal: true

require 'test_helper'

module Railswatch
  class EventsTest < ActiveSupport::TestCase
    test 'create_event' do
      assert_nothing_raised do
        Railswatch.create_event(name: 'test', options: {
                                  borderColor: '#00E396',
                                  label: {
                                    borderColor: '#00E396',
                                    orientation: 'horizontal',
                                    text: 'test'
                                  }
                                })
      end

      events = Railswatch::Events::Record.all
      assert_equal events.size, 1
      assert_equal events.first.name, 'test'
      assert_equal events.first.options, {
        borderColor: '#00E396',
        label: {
          borderColor: '#00E396',
          orientation: 'horizontal',
          text: 'test'
        }
      }.deep_stringify_keys
    end
  end
end
