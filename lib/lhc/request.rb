require 'typhoeus'

class LHC::Request

  attr_accessor :response, :options

  def initialize(options)
    self.options = options.deep_dup
    merge_options_from_config!
    inject_url_params!
    self.iprocessor = LHC::InterceptorProcessor.new(self)
    self.raw = create_request
    iprocessor.intercept(:before_request, self)
    raw.run unless response
  end

  def add_param(param)
    raw.options[:params] ||= {}
    raw.options[:params].merge!(param)
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

  def merge_options_from_config!
    return unless (config = LHC::Config[options[:url]])
    options.deep_merge!(config.options)
    options[:url] = config.endpoint
  end

  def inject_url_params!
    config = LHC::Config[options[:url]]
    endpoint = LHC::Endpoint.new(config.try(:endpoint) || options[:url])
    options[:url] = endpoint.inject(options[:params])
    endpoint.remove_injected_params!(options[:params])
  end

  def on_complete(response)
    self.response ||= LHC::Response.new(response, self)
    iprocessor.intercept(:after_response, self.response)
    if self.response.code.to_s[/^(2\d\d+)/]
      on_success
    else
      on_error
    end
  end

  def on_success
  end

  def on_error
    error = LHC::Error.find(response.code)
    fail error.new("#{response.code} #{response.body}", response)
  end
end
