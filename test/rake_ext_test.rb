# frozen_string_literal: true

require 'test_helper'
require 'rake'

Object.send(:remove_const, :APP_RAKEFILE) if defined?(APP_RAKEFILE) # HACK: for warning
APP_RAKEFILE = File.expand_path('../test/dummy/Rakefile', __dir__)
load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake' if Gem::Version.new(Rails.version) < Gem::Version.new('8.1.0')

require 'bundler/gem_tasks'
require 'rake/testtask'
require_relative '../lib/railswatch/gems/rake_ext'

class RakeExtTest < ActiveSupport::TestCase
  # this test works only when runing "bundle exec rake test"
  test 'can exclude rake tasks' do
    reset_storage
    Railswatch::Gems::RakeExt.init

    Railswatch.skipable_rake_tasks = ['db:version']
    count_before = count_records
    subject = Rake::Task['db:version']
    subject.invoke({})
    assert_equal count_before, count_records

    Railswatch.skipable_rake_tasks = []
    count_before = count_records
    subject = Rake::Task['db:version']
    subject.invoke({})
    assert_equal count_before + 1, count_records
  end

  def count_records
    datasource = Railswatch::DataSource.new(query: {}, type: :rake)
    db = datasource.db
    Railswatch::Reports::RecentRequestsReport.new(db).data.size
  end
end
