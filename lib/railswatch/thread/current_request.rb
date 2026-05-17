# frozen_string_literal: true

module Railswatch
  class CurrentRequest
    attr_reader :request_id, :tracings, :ignore
    attr_accessor :data, :record

    def self.init
      Thread.current[:rp_current_request] ||= CurrentRequest.new(SecureRandom.hex(16))
    end

    def self.current
      CurrentRequest.init
    end

    def self.cleanup
      Railswatch.log(
        '----------------------------------------------------> ' \
        "CurrentRequest.cleanup !!!!!!!!!!!! -------------------------\n\n"
      )
      Railswatch.skip = false
      Thread.current[:rp_current_request] = nil
    end

    def initialize(request_id)
      @request_id = request_id
      @tracings = []
      @ignore = Set.new
      @data = nil
      @record = nil
    end

    def trace(options = {})
      @tracings << options.merge(time: Railswatch::Utils.time.to_i)
    end
  end
end
