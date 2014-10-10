require 'typhoeus'

class LHC::Request

  attr_accessor :response, :raw_request, :opt_in, :opt_out

  def initialize(options)
    opt(options)
    self.raw_request = create_request(options)
    LHC::Interceptor.intercept!(:before_request, self)
    raw_request.run
    LHC::Interceptor.intercept!(:after_request, self)
    LHC::Interceptor.intercept!(:before_response, self)
    self
  end

  # Store and provide interceptors either opt-in or opt-out in request and remove from options
  def opt(options)
    self.opt_in = Array(options.delete(:opt_in)) || []
    self.opt_out = Array(options.delete(:opt_out)) || []
  end

  def options
    raw_request.options
  end

  def add_param(param)
    raw_request.options[:params] ||= {}
    raw_request.options[:params].merge!(param)
  end

  private

  def create_request(options)
    options = options.merge(options_from_config(options)) if LHC::Config[options[:url]]
    request = Typhoeus::Request.new(options.delete(:url), options)
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
    LHC::Interceptor.intercept!(:after_response, self.response)
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
