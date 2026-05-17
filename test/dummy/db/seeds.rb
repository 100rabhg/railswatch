# frozen_string_literal: true

require 'securerandom'

puts "Clearing existing data..."
Railswatch::Models::RequestRecord.delete_all
Railswatch::Models::TraceRecord.delete_all
Railswatch::Models::SidekiqRecord.delete_all
Railswatch::Models::DelayedJobRecord.delete_all
Railswatch::Models::RakeRecord.delete_all
Railswatch::Models::GrapeRecord.delete_all
Railswatch::Models::CustomRecord.delete_all
Railswatch::Models::ResourceRecord.delete_all

puts "Seeding request records..."
controllers = %w[
  PaymentsController OrdersController UsersController
  ProductsController SessionsController HomeController
  AdminController ApiController CartController CheckoutController
]
actions = %w[index show create update destroy new edit]
formats = %w[html json xml]
methods = %w[GET POST PUT PATCH DELETE]
paths = [
  '/payments', '/payments/charge', '/orders', '/orders/new',
  '/users', '/users/1', '/users/1/edit', '/products',
  '/api/v1/orders', '/api/v1/products', '/cart', '/checkout',
  '/admin/dashboard', '/admin/users', '/sessions/new'
]

now = Time.now
request_ids = []

50.times do
  controller = controllers.sample
  action = actions.sample
  status = ([200] * 10 + [201, 301, 302, 404, 422, 500]).sample.to_s
  duration = rand(50..800) + rand.round(2)
  occurred_at = now - rand(0..360).minutes - rand(0..59).seconds
  request_id = SecureRandom.uuid
  request_ids << request_id

  exception = nil
  backtrace = nil
  if status == '500'
    exception = [
      'NoMethodError: undefined method `charge` for nil:NilClass',
      'ActiveRecord::RecordNotFound: Could not find Order with id=999',
      'Stripe::CardError: Your card has insufficient funds.',
      'ArgumentError: wrong number of arguments'
    ].sample
    backtrace = "app/controllers/#{controller.underscore}.rb:42:in perform\napp/controllers/application_controller.rb:15:in call"
  end

  record = Railswatch::Models::RequestRecord.new(
    controller:       controller,
    action:           action,
    format:           formats.sample,
    status:           status,
    http_method:      methods.sample,
    path:             paths.sample,
    request_id:       request_id,
    duration_ms:      duration.round(2),
    view_runtime_ms:  (duration * rand(0.3..0.6)).round(2),
    db_runtime_ms:    (duration * rand(0.1..0.3)).round(2),
    http_referer:     'http://localhost:3000/',
    exception:        exception,
    backtrace:        backtrace,
    occurred_at:      occurred_at
  )
  record.save!
end

puts "Seeding trace records..."
request_ids.first(15).each do |req_id|
  occurred_at = now - rand(0..300).minutes
  entries = [
    { type: 'sql', sql: 'SELECT "users".* FROM "users" WHERE "users"."id" = $1',       duration_ms: rand(5..50).to_f },
    { type: 'sql', sql: 'SELECT "orders".* FROM "orders" WHERE "orders"."user_id" = $1', duration_ms: rand(10..80).to_f },
    { type: 'view', name: 'app/views/orders/index.html.erb',                            duration_ms: rand(20..150).to_f },
    { type: 'sql', sql: 'UPDATE "orders" SET "status" = $1 WHERE "orders"."id" = $2',   duration_ms: rand(5..30).to_f }
  ]

  Railswatch::Models::TraceRecord.create!(
    request_id:  req_id,
    entries:     entries.to_json,
    occurred_at: occurred_at
  )
end

puts "Seeding Sidekiq records..."
workers = %w[EmailWorker PaymentWorker NotificationWorker ReportWorker DataSyncWorker CleanupWorker ImageProcessingWorker]
queues  = %w[default critical mailers reports]

20.times do
  worker     = workers.sample
  status     = (['complete'] * 7 + %w[failed retry]).sample
  duration   = rand(200..5000).to_f
  occurred_at = now - rand(0..360).minutes
  jid        = SecureRandom.hex(12)
  enqueued   = occurred_at - rand(1..10).seconds

  Railswatch::Models::SidekiqRecord.create!(
    queue:           queues.sample,
    worker:          worker,
    jid:             jid,
    enqueued_ati:    enqueued.to_i,
    start_timei:     occurred_at.to_i,
    status:          status,
    duration_ms:     duration.round(2),
    message:         (status == 'failed' ? "RuntimeError: Something went wrong in #{worker}" : nil),
    job_args:        '["arg1","arg2"]',
    error_backtrace: (status == 'failed' ? "app/workers/#{worker.underscore}.rb:23:in perform" : nil),
    occurred_at:     occurred_at
  )
end

puts "Seeding Delayed Job records..."
dj_classes = %w[SendEmailJob GenerateReportJob ProcessPaymentJob SyncDataJob CleanupJob]

10.times do
  klass       = dj_classes.sample
  status      = (['complete'] * 6 + ['failed']).sample
  occurred_at = now - rand(0..300).minutes

  Railswatch::Models::DelayedJobRecord.create!(
    jid:             SecureRandom.uuid,
    source_type:     'ActiveJob',
    class_name:      klass,
    method_name:     'perform',
    status:          status,
    duration_ms:     rand(500..8000).to_f.round(2),
    job_args:        "{\"user_id\": #{rand(1..100)}}",
    error_message:   (status == 'failed' ? 'Timeout::Error: execution expired' : nil),
    error_backtrace: (status == 'failed' ? "app/jobs/#{klass.underscore}.rb:15:in perform" : nil),
    occurred_at:     occurred_at
  )
end

puts "Seeding Rake records..."
rake_tasks = %w[db:migrate assets:precompile tmp:clear cache:clear railswatch:prune report:generate data:import]

8.times do
  occurred_at = now - rand(0..480).minutes

  Railswatch::Models::RakeRecord.create!(
    task:        rake_tasks.sample,
    status:      (['complete'] * 7 + ['failed']).sample,
    duration_ms: rand(1000..30_000).to_f.round(2),
    occurred_at: occurred_at
  )
end

puts "Seeding Grape records..."
grape_paths   = ['/api/v1/users', '/api/v1/orders', '/api/v1/products', '/api/v2/analytics']
grape_methods = %w[GET POST PUT DELETE]

10.times do
  duration    = rand(50..600).to_f
  occurred_at = now - rand(0..360).minutes

  Railswatch::Models::GrapeRecord.create!(
    format:                    'json',
    path:                      grape_paths.sample,
    status:                    (%w[200] * 8 + %w[201 404 422 500]).sample,
    http_method:               grape_methods.sample,
    request_id:                SecureRandom.uuid,
    endpoint_render_grape_ms:  (duration * 0.2).round(2),
    endpoint_run_grape_ms:     (duration * 0.7).round(2),
    format_response_grape_ms:  (duration * 0.1).round(2),
    occurred_at:               occurred_at
  )
end

puts "Seeding custom event records..."
tags       = %w[payment.processed order.shipped user.signup email.sent cache.miss]
namespaces = %w[payments orders users notifications cache]

12.times do
  occurred_at = now - rand(0..360).minutes

  Railswatch::Models::CustomRecord.create!(
    tag_name:       tags.sample,
    namespace_name: namespaces.sample,
    status:         (%w[ok] * 8 + ['error']).sample,
    duration_ms:    rand(5..500).to_f.round(2),
    occurred_at:    occurred_at
  )
end

puts "Seeding resource monitor records..."
8.times do |i|
  occurred_at = now - (i * 15).minutes
  payload = {
    cpu:                  rand(10..70).to_f.round(1),
    memory_mb:            rand(200..800),
    disk_usage_percent:   rand(30..75).to_f.round(1)
  }

  Railswatch::Models::ResourceRecord.create!(
    server:      'web-01',
    context:     %w[rails sidekiq].sample,
    role:        'web',
    payload:     payload.to_json,
    occurred_at: occurred_at
  )
end

puts "Done! All dummy data seeded."
