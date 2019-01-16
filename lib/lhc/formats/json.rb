# frozen_string_literal: true

module LHC::Formats
  class JSON < LHC::Format
    include LHC::BasicMethodsConcern

    def self.request(options)
      options[:format] = new
      super(options)
    end

    def format_options(options)
      options[:headers] ||= {}
      no_content_type_header!(options)
      options[:headers]['Content-Type'] = 'application/json; charset=utf-8'
      no_accept_header!(options)
      options[:headers]['Accept'] = 'application/json; charset=utf-8'
      options
    end

    def as_json(input)
      parse(input, Hash)
    end

    def as_open_struct(input)
      parse(input, OpenStruct)
    end

    def to_body(input)
      if input.is_a?(String)
        input
      else
        input.to_json
      end
    end

    def to_s
      'json'
    end

    def to_sym
      to_s.to_sym
    end

    private

    def parse(input, object_class)
      ::JSON.parse(input, object_class: object_class)
    rescue ::JSON::ParserError => e
      raise LHC::ParserError.new(e.message, input)
    end
  end
end
