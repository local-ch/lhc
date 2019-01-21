# frozen_string_literal: true

module LHC
  module FormatsConcern
    extend ActiveSupport::Concern

    module ClassMethods
      def json
        LHC::Formats::JSON
      end

      def multipart
        LHC::Formats::Multipart
      end

      def plain
        LHC::Formats::Plain
      end
    end
  end
end
