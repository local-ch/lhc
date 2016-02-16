class JsonFormat
  include LHC::BasicMethods

  def self.request(options)
    options[:headers] ||= {}
    options[:headers]['Content-Type'] = 'application/json'
    options[:format] = new
    super(options)
  end

  def parse(response)
    JSON.parse(response.body, object_class: OpenStruct)
  rescue JSON::ParserError => e
    raise LHC::ParserError.new(e.message, response)
  end

  def to_s
    'json'
  end

  def to_sym
    to_s.to_sym
  end
end
