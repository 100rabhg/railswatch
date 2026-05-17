# frozen_string_literal: true

require 'test_helper'
require 'sidekiq/testing'

class SidekiqTest < ActiveSupport::TestCase
  test 'works' do
    SimpleWorker.new.perform

    s = Railswatch::Gems::SidekiqExt.new
    res = s.call('worker', 'msg', -> {}) do
      40 + 2
    end

    assert_equal 42, res
  end

  test 'sidekiq worker with error' do
    reset_storage

    begin
      s = Railswatch::Gems::SidekiqExt.new
      s.call('worker', 'msg', -> {}) do
        1 / 0
      end
    rescue StandardError
      'ignore me'
    end

    datasource = Railswatch::DataSource.new(query: {}, type: :sidekiq)
    db = datasource.db
    assert_equal db.data.last.status, 'exception'
  end
end
