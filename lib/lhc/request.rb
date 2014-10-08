require 'typhoeus'

class LHC::Request

  attr_accessor :response

  def initialize(options)
    Typhoeus::Hydra.hydra.queue request(options)
    Typhoeus::Hydra.hydra.run
    self
  end

  private

  def request(options)
    # params = options[:params] unless options[:method] == :post
    # body = options[:params].to_json if options[:method] == :post
    options.merge!(url: compute_url(options[:url], options[:params]))
    options.merge(followlocation: true) unless options[:followlocation]
    request = Typhoeus::Request.new(options.delete(:url), options)
    request.on_complete { |response| on_complete(response) }
    request
  end

  def compute_url(url, params = {})
    return url unless url.is_a? Symbol
    configuration = LHC::Config[url] || fail("No endpoint found for #{url}")
    endpoint = LHC::Endpoint.new(configuration[:endpoint])
    params = params.merge(configuration.params)
    endpoint.inject(params)
  end

  def on_complete(response)
    self.response = LHC::Response.new(response)
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
