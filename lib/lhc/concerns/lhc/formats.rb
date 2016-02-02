module LHC
  module Formats
    extend ActiveSupport::Concern

    module ClassMethods
      def json
        JsonFormat
      end
    end
  end
end
