# frozen_string_literal: true

class CrashWorker
  include Sidekiq::Worker

  def perform(*_args)
    1 / 0
  end
end
