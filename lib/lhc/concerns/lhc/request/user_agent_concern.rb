# frozen_string_literal: true

require 'active_support'
require 'lhc/version'

module LHC
  class Request
    module UserAgentConcern
      extend ActiveSupport::Concern

      included do
        Typhoeus::Config.user_agent = begin
          version = LHC::VERSION
          application = nil
          if defined?(Rails)
            app_class = Rails.application.class
            application = app_class.module_parent_name
          end

          "LHC (#{[version, application].compact.join('; ')}) [https://github.com/local-ch/lhc]"
        end
      end
    end
  end
end
