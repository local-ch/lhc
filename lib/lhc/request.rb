require 'typhoeus'

class LHC::Request

  attr_accessor :response, :opt_in, :opt_out

  def initialize(options)
    opt_interceptors(options)
    self.raw = create_request(options)
    LHC::Interceptor.intercept!(:before_request, self)
    raw.run
  rescue LHC::ImmediateInterception => e
    self.response = LHC::Response.new(e.response, self) if e.response
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

  attr_accessor :raw

  def create_request(options)
    options = options.merge(options_from_config(options)) if LHC::Config[options[:url]]
    request = Typhoeus::Request.new(options.delete(:url), options)
    request.on_headers do |response|
      LHC::Interceptor.intercept!(:after_request, self)
      LHC::Interceptor.intercept!(:before_response, self)
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
