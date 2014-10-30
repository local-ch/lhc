require 'active_support'

module LHC

  module DefaultInterceptors
    extend ActiveSupport::Concern

    module ClassMethods

      def default_interceptors=(interceptors)
        LHC::InterceptorProcessor.interceptors = interceptors
      end

      def default_interceptors
        LHC::InterceptorProcessor.interceptors
      end
    end
  end
end
