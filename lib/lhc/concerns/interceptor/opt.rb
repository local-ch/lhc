require 'active_support'

module LHC

  class Interceptor

    module Opt
      extend ActiveSupport::Concern

      module ClassMethods

        cattr_accessor :opt
        @@opt = :out

        def opt_in
          @@opt = :in
        end
      end
    end
  end
end
