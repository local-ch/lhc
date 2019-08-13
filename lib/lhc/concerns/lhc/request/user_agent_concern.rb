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
          application = defined?(Rails) ? Rails.application.class.module_parent_name : nil
          "LHC (#{[version, application].compact.join('; ')}) [https://github.com/local-ch/lhc]"
        end
      end
    end
  end
end
