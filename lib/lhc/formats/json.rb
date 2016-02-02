module JsonFormat
  include LHC::BasicMethods

  def self.request(options)
    options[:headers] ||= {}
    options[:headers]['Content-Type'] = 'application/json'
    super(options)
  end
end
