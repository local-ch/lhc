module LHC
  module FormatsConcern
    extend ActiveSupport::Concern

    module ClassMethods
      def json
        LHC::Formats::JSON
      end
    end
  end
end
