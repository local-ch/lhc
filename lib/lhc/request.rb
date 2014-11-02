require 'typhoeus'

# The request is doing an http-request using typhoeus.
# It provides functionalities to access and alter request data
# and it communicates with interceptors.
class LHC::Request

  attr_accessor :response, :options

  def initialize(options)
    self.options = options.deep_dup
    use_configured_endpoint!
    generate_url_from_pattern!
    self.iprocessor = LHC::InterceptorProcessor.new(self)
    self.raw = create_request
    iprocessor.intercept(:before_request, self)
    raw.run unless response
  end

  def merge_params!(hash)
    raw.options[:params] = options[:params] ||= {}
    options[:params].merge!(hash)
    raw.options[:params].merge!(hash)
  end

  def url
    raw.base_url || options[:url]
  end

  def method
    (raw.options[:method] || options[:method] || :get).to_sym
  end

  private

  attr_accessor :raw, :iprocessor

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
  # by injecting values either from params or config
  def generate_url_from_pattern!
    endpoint = LHC::Endpoint.new(options[:url])
    options[:url] = endpoint.inject(options[:params])
    endpoint.remove_injected_params!(options[:params])
  end

  def on_complete(response)
    self.response ||= LHC::Response.new(response, self)
    iprocessor.intercept(:after_response, self.response)
    on_error unless self.response.code.to_s[/^(2\d\d+)/]
  end

  def on_error
    error = LHC::Error.find(response)
    fail error.new("#{response.code} #{response.body}", response)
  end
end
