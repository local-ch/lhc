module LHC
  module FormatsConcern
    extend ActiveSupport::Concern

    module ClassMethods
      def json
        LHC::Formats::JSON
      end
      
      def unformatted
        LHC::Formats::Unformatted
      end
    end
  end
end
