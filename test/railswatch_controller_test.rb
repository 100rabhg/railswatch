# frozen_string_literal: true

require 'test_helper'

class RailswatchControllerTest < ActionDispatch::IntegrationTest
  setup do
    reset_storage
    Railswatch.skip = false
    @original_verify_access_proc = Railswatch.verify_access_proc
    Railswatch.verify_access_proc = proc { |_controller| true }
    User.create(first_name: 'John', age: 20)
  end

  teardown do
    Railswatch.verify_access_proc = @original_verify_access_proc
  end

  def requests_report_data
    source = Railswatch::DataSource.new(type: :requests)
    Railswatch::Reports::RequestsReport.new(source.db, group: :controller_action_format).data
  end

  test 'should get home page' do
    assert_equal requests_report_data.size, 0
    setup_db
    assert_equal requests_report_data.size, 1
    get '/'
    assert_equal requests_report_data.size, 2
    assert_response :success
  end

  test 'should respect ignored_endpoints configuration value' do
    assert_equal requests_report_data.size, 0
    get '/home/contact'
    assert_equal requests_report_data.size, 1
    assert_equal requests_report_data.first[:group], 'HomeController#contact|html'
    reset_storage
    assert_equal requests_report_data.size, 0

    original_ignored_endpoints = Railswatch.ignored_endpoints
    Railswatch.ignored_endpoints = ['HomeController#contact']
    get '/home/contact'
    assert_equal requests_report_data.size, 0
    Railswatch.ignored_endpoints = original_ignored_endpoints
  end

  test 'should respect ignored_paths configuration value' do
    original_ignored_paths = Railswatch.ignored_paths
    Railswatch.ignored_paths = ['/home']
    get '/home/contact'
    assert_equal requests_report_data.size, 0
    Railswatch.ignored_paths = original_ignored_paths
  end

  test 'should get index' do
    setup_db
    assert_equal requests_report_data.size, 1
    get '/railswatch'
    # make sure railswatch paths are ignored
    assert_equal requests_report_data.size, 1
    assert_response :success
  end

  test 'should get index with params' do
    setup_db
    get '/railswatch', params: { controller_eq: 'Home', action_eq: 'index' }
    assert_response :success
  end

  test 'should get summary with params' do
    setup_db
    get '/railswatch/summary', params: { controller_eq: 'Home', action_eq: 'index' }, xhr: true
    assert_response :success

    get '/railswatch/summary', params: { controller_eq: 'Home', action_eq: 'index' }, xhr: false
    assert_response :success
  end

  test 'should get home pages' do
    get '/home/about'
    assert_response :success
    get '/home/blog'
    assert_response :success
  end

  test 'should get about page' do
    get '/account/site/about'
    assert_response :success
  end

  test 'should get account other pages' do
    get '/account/site/not_found'
    assert_response :not_found

    get '/account/site/is_redirect'
    assert_response :redirect
  end

  test 'should get crashes with params' do
    begin
      get '/account/site/crash'
    rescue StandardError
      nil
    end

    get '/railswatch/crashes'
    assert_response :success
    assert response.body.include?('Account::SiteController')
  end

  test 'should get requests with params' do
    setup_db
    get '/railswatch/requests'
    assert_response :success
  end

  test 'should get recent with params' do
    setup_db
    get '/railswatch/recent'
    assert_response :success

    get '/railswatch/recent', xhr: true
    assert_response :success
  end

  test 'should get slow with params' do
    setup_db
    get '/railswatch/slow'
    assert_response :success
  end

  test 'should get sidekiq with params' do
    setup_db
    setup_sidekiq_db
    get '/railswatch/sidekiq'
    assert_response :success
  end

  test 'should get delayed_job with params' do
    setup_db
    setup_sidekiq_db
    get '/railswatch/delayed_job'
    assert_response :success
  end

  test 'should get rake' do
    setup_db
    setup_rake_db
    get '/railswatch/rake'
    assert_response :success
  end

  test 'should get custom' do
    setup_db
    get '/'
    get '/railswatch/custom'
    assert_response :success
  end

  test 'should get grape page' do
    setup_db
    setup_grape_db
    get '/api/users'
    get '/api/ping'
    get '/api/crash'
    get '/railswatch/grape'
    assert_response :success
  end

  test 'resources tab' do
    setup_db

    Railswatch::SystemMonitor::ResourcesMonitor.new('rails', 'web123').run

    get '/railswatch/resources'
    assert_response :success
    assert response.body.include?('web123')
  end

  test 'should get trace with params' do
    setup_db(dummy_event(request_id: '112233'))
    Railswatch::Models::TraceRecord.new(request_id: '112233', value: [
                                          { group: :db, sql: 'select', duration: 111 },
                                          { group: :view, message: 'rendering (Duration: 11.3ms)' }
                                        ]).save

    get '/railswatch/trace/112233', xhr: true
    assert_response :success

    get '/railswatch/trace/112233', xhr: false
    assert_response :success
  end

  # CSV export tests

  test 'crashes CSV export' do
    begin
      get '/account/site/crash'
    rescue StandardError
      nil
    end

    get '/railswatch/crashes.csv'
    assert_response :success
    assert_equal 'text/csv', response.content_type
    assert_includes response.body, 'controller'
    assert_includes response.body, 'Account::SiteController'
  end

  test 'requests CSV export' do
    setup_db(dummy_event(controller: 'Users', action: 'show'))

    get '/railswatch/requests.csv'
    assert_response :success
    assert_equal 'text/csv', response.content_type
    assert_includes response.body, 'group'
    assert_includes response.body, 'Users#show'
  end

  test 'recent CSV export' do
    setup_db(dummy_event(controller: 'Orders', action: 'index', path: '/orders'))

    get '/railswatch/recent.csv'
    assert_response :success
    assert_equal 'text/csv', response.content_type
    assert_includes response.body, 'controller'
    assert_includes response.body, 'Orders'
    assert_includes response.body, '/orders'
  end

  test 'slow CSV export' do
    event = dummy_event(controller: 'Reports', action: 'generate')
    event.duration = 1000 # exceed the 500ms threshold
    setup_db(event)

    get '/railswatch/slow.csv'
    assert_response :success
    assert_equal 'text/csv', response.content_type
    assert_includes response.body, 'controller'
    assert_includes response.body, 'Reports'
  end
end
