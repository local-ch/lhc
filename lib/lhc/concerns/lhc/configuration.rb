require 'active_support'

module LHC

  module Configuration
    extend ActiveSupport::Concern

    module ClassMethods

      def config
        LHC::Config.instance
      end
    end
  end
end
