# frozen_string_literal: true

require_relative 'base_controller'

module Railswatch
  class RailswatchController < BaseController
    protect_from_forgery except: :recent

    if Railswatch.enabled
      def index
        @datasource = Railswatch::DataSource.new(**prepare_query(params), type: :requests)
        assign_dashboard_reports(@datasource.db)
        @widgets = build_dashboard_widgets
      end

      def resources
        @datasource = Railswatch::DataSource.new(
          **prepare_query(params),
          type: :resources,
          days: Railswatch::Utils.days(Railswatch.system_monitor_duration)
        )
        db = @datasource.db

        @resources_report = Railswatch::Reports::ResourcesReport.new(db)
      end

      def summary # rubocop:disable Metrics/MethodLength
        @datasource = Railswatch::DataSource.new(**prepare_query(params), type: :requests)
        db = @datasource.db

        @throughput_report_data = Railswatch::Reports::ThroughputReport.new(db).data
        @response_time_report_data = Railswatch::Reports::ResponseTimeReport.new(db).data
        @data = Railswatch::Reports::BreakdownReport.new(db, title: 'Requests').data
        respond_to do |format|
          format.js
          format.any do
            render plain: "Doesn't open in new window. Wait until full page load."
          end
        end
      end

      def trace
        @record = Railswatch::Models::RequestRecord.find_by(request_id: params[:id])
        @data = Railswatch::Reports::TraceReport.new(request_id: params[:id]).data
        respond_to do |format|
          format.js
          format.any do
            render plain: "Doesn't open in new window. Wait until full page load."
          end
        end
      end

      def crashes
        @datasource = Railswatch::DataSource.new(**prepare_query({ status_eq: 500 }), type: :requests)
        @table = Widgets::CrashesTable.new(@datasource)

        respond_to do |format|
          format.html
          format.csv do
            export_to_csv 'error_report', @table.data
          end
        end
      end

      def requests
        @datasource = Railswatch::DataSource.new(**prepare_query(params), type: :requests)
        @table = Widgets::RequestsTable.new(@datasource)

        respond_to do |format|
          format.html
          format.csv do
            export_to_csv 'requests_report', @table.data
          end
        end
      end

      def recent
        @datasource = Railswatch::DataSource.new(**prepare_query(params), type: :requests)
        @table = Widgets::RecentRequestsTable.new(@datasource)

        respond_to do |format|
          format.html
          format.csv do
            export_to_csv 'recent_requests_report', @table.data
          end
        end
      end

      def slow
        @datasource = Railswatch::DataSource.new(**prepare_query(params), type: :requests)
        @table = Widgets::SlowRequestsTable.new(@datasource)

        respond_to do |format|
          format.html
          format.csv do
            export_to_csv 'slow_requests_report', @table.data
          end
        end
      end

      def sidekiq
        @datasource = Railswatch::DataSource.new(**prepare_query(params), type: :sidekiq)
        @widgets = [
          Widgets::ThroughputChart.new(@datasource, subtitle: 'Sidekiq Workers Throughput Report', legend: 'Jobs',
                                                    units: 'jobs / minute'),
          Widgets::ResponseTimeChart.new(@datasource, subtitle: 'Average Execution Time'),
          Widgets::SidekiqJobsTable.new(@datasource)
        ]
      end

      def delayed_job
        @datasource = Railswatch::DataSource.new(**prepare_query(params), type: :delayed_job)
        @widgets = [
          Widgets::ThroughputChart.new(@datasource, subtitle: 'Delayed::Job Workers Throughput Report', legend: 'Jobs',
                                                    units: 'jobs / minute'),
          Widgets::ResponseTimeChart.new(@datasource, subtitle: 'Average Execution Time'),
          Widgets::DelayedJobTable.new(@datasource)
        ]
      end

      def custom
        @datasource = Railswatch::DataSource.new(**prepare_query(params), type: :custom)
        @widgets = [
          Widgets::CustomEventsTable.new(@datasource),
          Widgets::ThroughputChart.new(@datasource, subtitle: 'Custom Events Throughput Report', legend: 'Events',
                                                    units: 'events / minute'),
          Widgets::ResponseTimeChart.new(@datasource, subtitle: 'Average Execution Time')
        ]
      end

      def grape
        @datasource = Railswatch::DataSource.new(**prepare_query(params), type: :grape)
        @widgets = [
          Widgets::ThroughputChart.new(@datasource, subtitle: 'Grape Throughput Report'),
          Widgets::GrapeRequestsTable.new(@datasource)
        ]
      end

      def rake
        @datasource = Railswatch::DataSource.new(**prepare_query(params), type: :rake)
        @widgets = [
          Widgets::RakeTasksTable.new(@datasource),
          Widgets::ThroughputChart.new(@datasource, subtitle: 'Rake Throughput Report', legend: 'Tasks',
                                                    units: 'tasks / minute')
        ]
      end

      private

      def prepare_query(query = {})
        Railswatch::Rails::QueryBuilder.compose_from(query)
      end

      def assign_dashboard_reports(db)
        @overview = Railswatch::Reports::OverviewReport.new(db).data
        @traffic_leaders = top_request_rows(db, :count)
        @latency_leaders = top_request_rows(db, :p95_duration)
      end

      def top_request_rows(db, sort)
        Railswatch::Reports::RequestsReport.new(
          db,
          group: :controller_action,
          sort: sort
        ).data.first(5)
      end

      def build_dashboard_widgets
        Railswatch.dashboard_charts.map do |row|
          row.is_a?(Array) ? build_widget_row(row) : build_widget(row)
        end
      end

      def build_widget_row(row)
        row.map { |class_name| build_widget(class_name) }
      end

      def build_widget(class_name)
        Widgets.const_get(class_name).new(@datasource)
      end
    end
  end
end
