require 'typhoeus'

class LHC::Request

  attr_accessor :response, :opt_in, :opt_out

  def initialize(options)
    opt_interceptors(options)
    self.iprocessor = LHC::InterceptorProcessor.new
    self.raw = create_request(options)
    iprocessor.intercept(:before_request, self)
    if iprocessor.response
      self.response = LHC::Response.new(iprocessor.response, self)
    else
      raw.run
    end
  end

  # Store and provide interceptors either opt-in or opt-out in request and remove from options
  def opt_interceptors(options)
    self.opt_in = Array(options.delete(:opt_in)) || []
    self.opt_out = Array(options.delete(:opt_out)) || []
  end

  def options
    raw.options
  end

  def add_param(param)
    raw.options[:params] ||= {}
    raw.options[:params].merge!(param)
  end

  def url
    raw.base_url
  end

  private

  attr_accessor :raw, :iprocessor

  def create_request(options)
    options = options.merge(options_from_config(options)) if LHC::Config[options[:url]]
    request = Typhoeus::Request.new(options.delete(:url), options)
    request.on_headers do |response|
      iprocessor.intercept(:after_request, self)
      iprocessor.intercept(:before_response, self)
    end
    request.on_complete { |response| on_complete(response) }
    request
  end

  def options_from_config(options)
    url = options[:url]
    configuration = LHC::Config[url]
    options = options.deep_merge(configuration.options)
    options = compute_url_options!(options) if url.is_a?(Symbol)
    options
  end

  def compute_url_options!(options)
    configuration = LHC::Config[options[:url]] || fail("No endpoint found for #{options[:url]}")
    options = options.deep_merge(configuration.options)
    endpoint = LHC::Endpoint.new(configuration[:endpoint])
    options[:url] = endpoint.inject(options[:params])
    endpoint.remove_injected_params!(options[:params])
    options
  end

  def on_complete(response)
    self.response = LHC::Response.new(response, self)
    iprocessor.intercept(:after_response, self.response)
    self.response = LHC::Response.new(iprocessor.response, self) if iprocessor.response
    if response.code.to_s[/^(2\d\d+)/]
      on_success(response)
    else
      on_error(response)
    end
  end

  def on_success(response)
  end

  def on_error(response)
    error = LHC::Error.find(response.code)
    fail error.new("#{response.code} #{response.body}", response)
  end
end
