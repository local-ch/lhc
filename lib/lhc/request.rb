require 'typhoeus'

# The request is doing an http-request using typhoeus.
# It provides functionalities to access and alter request data
# and it communicates with interceptors.
class LHC::Request

  attr_accessor :response, :options, :raw

  def initialize(options, self_executing = true)
    self.options = options.deep_dup
    use_configured_endpoint!
    generate_url_from_pattern!
    self.iprocessor = LHC::InterceptorProcessor.new(self)
    self.raw = create_request
    iprocessor.intercept(:before_request, self)
    raw.run if !response && self_executing
  end

  def url
    raw.base_url || options[:url]
  end

  def method
    (raw.options[:method] || options[:method] || :get).to_sym
  end

  def headers
    raw.options.fetch(:headers, nil) || raw.options[:headers] = {}
  end

  def params
    raw.options.fetch(:params, nil) || raw.options[:params] = {}
  end

  private

  attr_accessor :iprocessor

  def create_request
    request = Typhoeus::Request.new(options[:url], typhoeusize(options))
    request.on_headers do
      iprocessor.intercept(:after_request, self)
      iprocessor.intercept(:before_response, self)
    end
    request.on_complete { |response| on_complete(response) }
    request
  end

  def typhoeusize(options)
    options = options.deep_dup
    options.delete :url
    options.delete :interceptors
    options
  end

  # Get configured endpoint and use it for doing the request.
  # Explicit request options are overriding configured options.
  def use_configured_endpoint!
    return unless (endpoint = LHC.config.endpoints[options[:url]])
    endpoint.options.deep_merge!(options)
    options.deep_merge!(endpoint.options)
    options[:url] = endpoint.url
  end

  # Generates URL from a URL pattern
  def generate_url_from_pattern!
    endpoint = LHC::Endpoint.new(options[:url])
    options[:url] = endpoint.compile(options[:params])
    endpoint.remove_interpolated_params!(options[:params])
  end

  def on_complete(response)
    self.response ||= LHC::Response.new(response, self)
    iprocessor.intercept(:after_response, self.response)
    on_error unless self.response.success?
  end

  def on_error
    error = LHC::Error.find(response)
    debug = []
    debug << "#{method} #{url}"
    debug << "Params: #{@options}"
    debug << "Options: #{@options}"
    debug << response.code
    debug << response.body
    fail error.new(debug.join("\n"), response)
  end
end
