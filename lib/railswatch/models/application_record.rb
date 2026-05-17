# frozen_string_literal: true

module Railswatch
  module Models
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true

      class << self
        def reset_storage_connection!
          target = Railswatch.database_connection_name.presence&.to_s
          if target.blank?
            remove_connection
          else
            establish_connection(resolve_connection_name(target).to_sym)
          end
        rescue ActiveRecord::ConnectionNotEstablished
          nil
        end

        private

        def resolve_connection_name(target)
          configs = ActiveRecord::Base.configurations.configs_for(env_name: ::Rails.env)
          return target if configs.any? { |config| config.name == target }

          "#{::Rails.env}_#{target}"
        end
      end
    end
  end
end
