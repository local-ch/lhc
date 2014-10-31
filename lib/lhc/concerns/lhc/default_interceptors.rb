require 'active_support'

module LHC

  module DefaultInterceptors
    extend ActiveSupport::Concern

    module ClassMethods

      def default_interceptors=(interceptors)
        LHC::Config.instance.default_interceptors = interceptors
      end

      def default_interceptors
        LHC::Config.instance.default_interceptors
      end
    end
  end
end
