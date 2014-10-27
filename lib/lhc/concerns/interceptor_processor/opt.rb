require 'active_support'

module LHC

  class InterceptorProcessor

    module Opt
      extend ActiveSupport::Concern

      def opted_out?(interceptor, target)
        opt = interceptor.class.opt
        opt_in = target.opt_in.include?(interceptor.class.name.underscore.to_sym)
        opt_out = target.opt_out.include?(interceptor.class.name.underscore.to_sym)
        (opt == :in && opt_in == false) || (opt == :out && opt_out == true)
      end
    end
  end
end
