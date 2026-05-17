# frozen_string_literal: true

if Rails.env.test? && defined?(Sidekiq)
  require 'sidekiq/testing'
  Sidekiq::Testing.fake!
end
