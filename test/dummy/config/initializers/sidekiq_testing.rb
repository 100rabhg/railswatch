# frozen_string_literal: true

Sidekiq.testing!(:fake) if Rails.env.test? && defined?(Sidekiq)
