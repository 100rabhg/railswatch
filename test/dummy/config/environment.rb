# frozen_string_literal: true

# Load and initialize the Rails application while silencing third-party boot
# warnings from gems that are exercised only by the dummy test app.
begin
  saved_verbose = $VERBOSE
  $VERBOSE = nil
  require_relative 'application'
  Rails.application.initialize!
ensure
  $VERBOSE = saved_verbose
end
