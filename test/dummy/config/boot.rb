# frozen_string_literal: true

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __dir__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)

# Load delayed_job here, before Rails, so Rails::Railtie is not yet defined.
# delayed/railtie.rb line 1 does `require 'delayed_job'` which creates a
# circular require when delayed_job.rb itself triggers the railtie. Loading
# without Rails present skips that railtie require entirely, breaking the cycle.
begin
  saved_verbose = $VERBOSE
  $VERBOSE = nil
  require 'delayed_job'
ensure
  $VERBOSE = saved_verbose
end
