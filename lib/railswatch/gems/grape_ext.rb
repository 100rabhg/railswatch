# frozen_string_literal: true

module Railswatch
  module Gems
    class GrapeExt
      class << self
        def init
          ActiveSupport::Notifications.subscribe(/grape/) do |name, start, finish, _id, payload|
            handle_grape_notification(name, start, finish, payload)
          end
        end

        def handle_grape_notification(name, start, finish, payload)
          req = setup_grape_request
          now = Railswatch::Utils.time
          set_record_fields(req, now)
          set_timing_field(req.record, name, start, finish)
          set_payload_fields(req.record, payload[:env]) if payload[:env]
          save_and_cleanup_if_needed(req, name, payload)
        end

        def setup_grape_request
          req = CurrentRequest.current
          req.ignore.add(:monitoring)
          req.data ||= {}
          req.record ||= Railswatch::Models::GrapeRecord.new(request_id: req.request_id)
          req
        end

        def set_record_fields(req, now)
          req.record.datetimei ||= now.to_i
          req.record.datetime ||= now.strftime(Railswatch::FORMAT)
        end

        def save_and_cleanup_if_needed(req, name, payload)
          return unless name == 'format_response.grape' || name_grape_expect_no_content?(req, name, payload)

          req.record.save
          CurrentRequest.cleanup
        end

        def name_grape_expect_no_content?(req, name, payload)
          expects_no_content = Rack::Utils::STATUS_WITH_NO_ENTITY_BODY.include?(req.record.status.to_i)
          name == 'endpoint_run.grape' && (payload[:endpoint]&.body.nil? || expects_no_content)
        end

        def set_timing_field(record, name, start, finish)
          return unless ['endpoint_render.grape', 'endpoint_run.grape', 'format_response.grape'].include?(name)

          record.send("#{name.tr('.', '_')}=", (finish - start) * 1000)
        end

        def set_payload_fields(record, env)
          endpoint = env['api.endpoint']

          record.status = endpoint&.status || env['api.response.status']
          record.format = env['api.format']
          record.method = env['REQUEST_METHOD']
          record.path = env['PATH_INFO']
        end
      end
    end
  end
end
