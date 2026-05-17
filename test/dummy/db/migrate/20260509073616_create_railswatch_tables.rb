# frozen_string_literal: true

class CreateRailswatchTables < ActiveRecord::Migration[7.0]
  def change
    create_table :railswatch_request_records do |t|
      t.string :controller
      t.string :action
      t.string :format
      t.string :status
      t.string :http_method
      t.string :path
      t.string :request_id, null: false
      t.float :duration_ms
      t.float :view_runtime_ms
      t.float :db_runtime_ms
      t.string :http_referer
      t.text :custom_data
      t.text :exception
      t.text :backtrace
      t.text :request_context
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :railswatch_request_records, :occurred_at
    add_index :railswatch_request_records, :request_id, unique: true
    add_index :railswatch_request_records, %i[status occurred_at],
              name: 'idx_rp_requests_on_status_and_occurred_at'
    add_index :railswatch_request_records, %i[controller action format occurred_at],
              name: 'idx_rp_requests_on_grouping_fields'

    create_table :railswatch_trace_records do |t|
      t.string :request_id, null: false
      t.text :entries
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :railswatch_trace_records, :request_id, unique: true
    add_index :railswatch_trace_records, :occurred_at

    create_table :railswatch_sidekiq_records do |t|
      t.string :queue
      t.string :worker
      t.string :jid, null: false
      t.integer :enqueued_ati
      t.integer :start_timei
      t.string :status
      t.float :duration_ms
      t.text :message
      t.text :job_args
      t.text :error_backtrace
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :railswatch_sidekiq_records, :occurred_at
    add_index :railswatch_sidekiq_records, %i[queue worker occurred_at],
              name: 'idx_rp_sidekiq_on_queue_worker_time'
    add_index :railswatch_sidekiq_records, :jid

    create_table :railswatch_delayed_job_records do |t|
      t.string :jid
      t.string :source_type
      t.string :class_name
      t.string :method_name
      t.string :status
      t.float :duration_ms
      t.text :job_args
      t.text :error_message
      t.text :error_backtrace
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :railswatch_delayed_job_records, :occurred_at
    add_index :railswatch_delayed_job_records, %i[status occurred_at], name: 'idx_rp_delayed_jobs_on_status_time'

    create_table :railswatch_grape_records do |t|
      t.string :format
      t.string :path
      t.string :status
      t.string :http_method
      t.string :request_id
      t.float :endpoint_render_grape_ms
      t.float :endpoint_run_grape_ms
      t.float :format_response_grape_ms
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :railswatch_grape_records, :occurred_at
    add_index :railswatch_grape_records, %i[status occurred_at], name: 'idx_rp_grape_on_status_time'

    create_table :railswatch_rake_records do |t|
      t.text :task
      t.string :status
      t.float :duration_ms
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :railswatch_rake_records, :occurred_at
    add_index :railswatch_rake_records, %i[status occurred_at], name: 'idx_rp_rake_on_status_time'

    create_table :railswatch_custom_records do |t|
      t.string :tag_name
      t.string :namespace_name
      t.string :status
      t.float :duration_ms
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :railswatch_custom_records, :occurred_at
    add_index :railswatch_custom_records, %i[status occurred_at], name: 'idx_rp_custom_on_status_time'

    create_table :railswatch_resource_records do |t|
      t.string :server
      t.string :context
      t.string :role
      t.text :payload
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :railswatch_resource_records, :occurred_at
    add_index :railswatch_resource_records, %i[server context role occurred_at],
              name: 'idx_rp_resources_on_server_context_role_time'

    create_table :railswatch_event_records do |t|
      t.string :name
      t.text :options
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :railswatch_event_records, :occurred_at
  end
end
