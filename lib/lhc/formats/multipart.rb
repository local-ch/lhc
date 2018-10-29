module LHC::Formats
  class Multipart
    include LHC::BasicMethodsConcern

    def self.request(options)
      options[:headers] ||= {}
      options[:headers]['Content-Type'] = 'multipart/form-data'
      options[:format] = new
      super(options)
    end

    def as_json(input)
      parse(input)
    end

    def as_open_struct(input)
      parse(input)
    end

    def to_body(input)
      input
    end

    def to_s
      'multipart'
    end

    def to_sym
      to_s.to_sym
    end

    private

    def parse(input)
      input
    end
  end
end
