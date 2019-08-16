# frozen_string_literal: true

require 'active_support'

module LHC
  module FixInvalidEncodingConcern
    extend ActiveSupport::Concern

    module ClassMethods
      # fix strings that contain non-UTF8 encoding in a forceful way
      # should none of the fix-attempts be successful,
      # an empty string is returned instead
      def fix_invalid_encoding(string)
        return string unless string.is_a?(String)
        result = string.dup

        # we assume it's ISO-8859-1 first
        if !result.valid_encoding? || !utf8?(result)
          result.encode!('UTF-8', 'ISO-8859-1', invalid: :replace, undef: :replace, replace: '')
        end

        # if it's still an issue, try with BINARY
        if !result.valid_encoding? || !utf8?(result)
          result.encode!('UTF-8', 'BINARY', invalid: :replace, undef: :replace, replace: '')
        end

        # if its STILL an issue, return an empty string :(
        if !result.valid_encoding? || !utf8?(result)
          result = ""
        end

        result
      end

      private

      def utf8?(string)
        string.encoding == Encoding::UTF_8
      end
    end
  end
end
