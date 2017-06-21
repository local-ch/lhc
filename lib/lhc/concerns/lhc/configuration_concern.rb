require 'active_support'

module LHC
  module ConfigurationConcern
    extend ActiveSupport::Concern

    module ClassMethods
      
      def config
        LHC::Config.instance
      end

      def configure
        LHC::Config.instance.reset
        yield config
      end
    end
  end
end
