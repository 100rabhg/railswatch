# frozen_string_literal: true

class AdvancedWorker
  include Sidekiq::Worker

  def perform(*_args)
    sleep(rand(1000) / 100.0)
  end
end
