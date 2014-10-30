require 'typhoeus'

class LHC::Request

  attr_accessor :response, :options

  def initialize(options)
    self.options = options
    merge_options_from_config!
    inject_url_params!
    self.iprocessor = LHC::InterceptorProcessor.new
    self.raw = create_request
    iprocessor.intercept(:before_request, self)
    if iprocessor.response
      self.response = LHC::Response.new(iprocessor.response, self)
    else
      raw.run
    end
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

  def create_request
    request = Typhoeus::Request.new(options[:url],
      method: options[:method] || :get,
      body: options[:body],
      params: options[:params],
      headers: options[:headers],
      followlocation: options[:followlocation],
      timeout: options[:timeout]
    )
    request.on_headers do
      iprocessor.intercept(:after_request, self)
      iprocessor.intercept(:before_response, self)
    end
    request.on_complete { |response| on_complete(response) }
    request
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
