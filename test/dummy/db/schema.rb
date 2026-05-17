# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_05_09_073616) do
  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "railswatch_custom_records", force: :cascade do |t|
    t.string "tag_name"
    t.string "namespace_name"
    t.string "status"
    t.float "duration_ms"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurred_at"], name: "index_railswatch_custom_records_on_occurred_at"
    t.index ["status", "occurred_at"], name: "idx_rp_custom_on_status_time"
  end

  create_table "railswatch_delayed_job_records", force: :cascade do |t|
    t.string "jid"
    t.string "source_type"
    t.string "class_name"
    t.string "method_name"
    t.string "status"
    t.float "duration_ms"
    t.text "job_args"
    t.text "error_message"
    t.text "error_backtrace"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurred_at"], name: "index_railswatch_delayed_job_records_on_occurred_at"
    t.index ["status", "occurred_at"], name: "idx_rp_delayed_jobs_on_status_time"
  end

  create_table "railswatch_event_records", force: :cascade do |t|
    t.string "name"
    t.text "options"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurred_at"], name: "index_railswatch_event_records_on_occurred_at"
  end

  create_table "railswatch_grape_records", force: :cascade do |t|
    t.string "format"
    t.string "path"
    t.string "status"
    t.string "http_method"
    t.string "request_id"
    t.float "endpoint_render_grape_ms"
    t.float "endpoint_run_grape_ms"
    t.float "format_response_grape_ms"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurred_at"], name: "index_railswatch_grape_records_on_occurred_at"
    t.index ["status", "occurred_at"], name: "idx_rp_grape_on_status_time"
  end

  create_table "railswatch_rake_records", force: :cascade do |t|
    t.text "task"
    t.string "status"
    t.float "duration_ms"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurred_at"], name: "index_railswatch_rake_records_on_occurred_at"
    t.index ["status", "occurred_at"], name: "idx_rp_rake_on_status_time"
  end

  create_table "railswatch_request_records", force: :cascade do |t|
    t.string "controller"
    t.string "action"
    t.string "format"
    t.string "status"
    t.string "http_method"
    t.string "path"
    t.string "request_id", null: false
    t.float "duration_ms"
    t.float "view_runtime_ms"
    t.float "db_runtime_ms"
    t.string "http_referer"
    t.text "custom_data"
    t.text "request_context"
    t.text "exception"
    t.text "backtrace"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["controller", "action", "format", "occurred_at"], name: "idx_rp_requests_on_grouping_fields"
    t.index ["occurred_at"], name: "index_railswatch_request_records_on_occurred_at"
    t.index ["request_id"], name: "index_railswatch_request_records_on_request_id", unique: true
    t.index ["status", "occurred_at"], name: "idx_rp_requests_on_status_and_occurred_at"
  end

  create_table "railswatch_resource_records", force: :cascade do |t|
    t.string "server"
    t.string "context"
    t.string "role"
    t.text "payload"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurred_at"], name: "index_railswatch_resource_records_on_occurred_at"
    t.index ["server", "context", "role", "occurred_at"], name: "idx_rp_resources_on_server_context_role_time"
  end

  create_table "railswatch_sidekiq_records", force: :cascade do |t|
    t.string "queue"
    t.string "worker"
    t.string "jid", null: false
    t.integer "enqueued_ati"
    t.integer "start_timei"
    t.string "status"
    t.float "duration_ms"
    t.text "message"
    t.text "job_args"
    t.text "error_backtrace"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jid"], name: "index_railswatch_sidekiq_records_on_jid"
    t.index ["occurred_at"], name: "index_railswatch_sidekiq_records_on_occurred_at"
    t.index ["queue", "worker", "occurred_at"], name: "idx_rp_sidekiq_on_queue_worker_time"
  end

  create_table "railswatch_trace_records", force: :cascade do |t|
    t.string "request_id", null: false
    t.text "entries"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurred_at"], name: "index_railswatch_trace_records_on_occurred_at"
    t.index ["request_id"], name: "index_railswatch_trace_records_on_request_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end
