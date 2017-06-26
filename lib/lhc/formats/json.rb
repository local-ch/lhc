module LHC::Formats
  class JSON
    include LHC::BasicMethodsConcern

    def self.request(options)
      options[:headers] ||= {}
      options[:headers]['Content-Type'] = 'application/json'
      options[:headers]['Accept'] = 'application/json'
      options[:format] = new
      super(options)
    end

    def as_json(response)
      parse(response, Hash)
    end

    def as_open_struct(response)
      parse(response, OpenStruct)
    end

    def to_s
      'json'
    end

    def to_sym
      to_s.to_sym
    end

    private

    def parse(response, object_class)
      ::JSON.parse(response.body, object_class: object_class)
    rescue ::JSON::ParserError => e
      raise LHC::ParserError.new(e.message, response)
    end
  end
end
