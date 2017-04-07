require 'typhoeus'
require 'uri'
require 'active_support/core_ext/object/deep_dup'

# The request is doing an http-request using typhoeus.
# It provides functionalities to access and alter request data
# and it communicates with interceptors.
class LHC::Request

  TYPHOEUS_OPTIONS ||= [:params, :method, :body, :headers, :follow_location]

  attr_accessor :response, :options, :raw, :format, :error_handler

  def initialize(options, self_executing = true)
    self.options = options.deep_dup || {}
    self.error_handler = options.delete :error_handler
    use_configured_endpoint!
    generate_url_from_template!
    self.iprocessor = LHC::InterceptorProcessor.new(self)
    self.raw = create_request
    self.format = options.delete('format') || JsonFormat.new
    iprocessor.intercept(:before_request, self)
    raw.run if self_executing && !response
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
    request = Typhoeus::Request.new(encode_url(options[:url]), typhoeusize(options))
    request.on_headers do
      iprocessor.intercept(:after_request, self)
      iprocessor.intercept(:before_response, self)
    end
    request.on_complete { |response| on_complete(response) }
    request
  end

  def encode_url(url)
    return url if url.nil?
    URI.escape(url)
  end

  def typhoeusize(options)
    options = options.deep_dup
    easy = Ethon::Easy.new
    options.delete(:url)
    options.each do |key, _v|
      next if TYPHOEUS_OPTIONS.include? key
      method = "#{key}="
      options.delete key unless easy.respond_to?(method)
    end
    options
  end

  # Get configured endpoint and use it for doing the request.
  # Explicit request options are overriding configured options.
  def use_configured_endpoint!
    endpoint = LHC.config.endpoints[options[:url]]
    return unless endpoint
    # explicit options override endpoint options
    new_options = endpoint.options.deep_merge(options)
    # set new options
    self.options = new_options
    options[:url] = endpoint.url
  end

  # Generates URL from a URL template
  def generate_url_from_template!
    endpoint = LHC::Endpoint.new(options[:url])
    params =
      if options[:body] && options[:body].length && (options[:headers] || {}).fetch('Content-Type', nil) == 'application/json'
        JSON.parse(options[:body]).merge(options[:params] || {}).deep_symbolize_keys
      else
        options[:params]
      end
    options[:url] = endpoint.compile(params)
    endpoint.remove_interpolated_params!(options[:params])
  end

  def on_complete(response)
    self.response ||= LHC::Response.new(response, self)
    iprocessor.intercept(:after_response, self.response)
    handle_error(self.response) unless self.response.success?
  end

  def handle_error(response)
    throw_error(response) unless error_handler
    response.body_replacement = error_handler.call(response)
  end

  def throw_error(response)
    error = LHC::Error.find(response)
    fail error.new(error, response)
  end
end
