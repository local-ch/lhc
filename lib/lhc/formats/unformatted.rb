module LHC::Formats
  class Unformatted
    include LHC::BasicMethodsConcern

    def self.request(options)
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
      'unformatted'
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
