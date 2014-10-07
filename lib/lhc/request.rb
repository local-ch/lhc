require 'typhoeus'

class LHC::Request

  attr_accessor :data

  def initialize(options)
    Typhoeus::Hydra.hydra.queue request(options)
    Typhoeus::Hydra.hydra.run
    self
  end

  private

  def request(options)
    merge_explicit_params!(options[:params])
    params = options[:params] unless options[:method] == :post
    body = options[:params].to_json if options[:method] == :post
    request = Typhoeus::Request.new(
      options[:url],
      method: options[:method] || :get,
      params: params,
      body: body,
      headers: { 'Content-Type' => 'application/json' },
      followlocation: true
    )
    request.on_complete { |response| on_complete(response) }
    request
  end

  def on_complete(response)
    if response.code.to_s[/^(2\d\d+)/]
      on_success(response)
    else
      on_error(response)
    end
  end

  def on_success(response)
    self.data = response.body
  end

  def on_error(response)
    error = LHC::Error.find(response.code)
    fail error.new("#{response.code} #{response.body}", response)
  end

   # Merge explicit params nested in 'params' namespace with original hash.
  def merge_explicit_params!(params)
    return true unless params
    explicit_params = params[:params]
    params.delete(:params)
    params.merge!(explicit_params) if explicit_params
  end
end
