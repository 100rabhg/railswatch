# frozen_string_literal: true

class SecondWorker
  include Sidekiq::Worker

  def perform(*_args)
    sleep(rand(1000) / 100.0)
  end
end
