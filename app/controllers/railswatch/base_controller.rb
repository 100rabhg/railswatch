# frozen_string_literal: true

module Railswatch
  class BaseController < ActionController::Base
    include Railswatch::Concerns::CsvExportable

    layout 'railswatch/layouts/railswatch'

    before_action :verify_access
    after_action :set_permissive_csp

    if Railswatch.http_basic_authentication_enabled
      http_basic_authenticate_with \
        name: Railswatch.http_basic_authentication_user_name,
        password: Railswatch.http_basic_authentication_password
    end

    def url_options
      Railswatch.url_options.nil? ? super : Railswatch.url_options
    end

    private

    def verify_access
      result = Railswatch.verify_access_proc.call(self)
      redirect_to('/', error: 'Access Denied', status: 401) unless result
    end

    def set_permissive_csp
      response.headers['Content-Security-Policy'] =
        "default-src 'self' https:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; " \
        "style-src 'self' 'unsafe-inline' https:"
    end
  end
end
