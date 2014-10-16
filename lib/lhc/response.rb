require 'typhoeus'

# A abstraction of a response.
# In this case we abstract the thphoues response.
class LHC::Response

  attr_accessor :request

  def initialize(raw, request)
    self.request = request
    self.raw = raw
  end

  # Access response data.
  # Cache parsing.
  def data
    @data ||= JSON.parse(raw.body, object_class: OpenStruct)
    @data
  end

  # List of interceptors opt-in
  def opt_in
    request.opt_in
  end

  # List of interceptors opt-out
  def opt_out
    request.opt_out
  end

  def body
    raw.body
  end

  def code
    raw.code
  end

  def headers
    raw.headers
  end

  def request_options
    raw.request.options
  end

  def request_url
    raw.request.base_url
  end

  def request_method
    raw.request.options.fetch(:method, :get).to_sym
  end

  # Provides response time in ms.
  def time
    (raw.time || 0) * 1000
  end

  private

  attr_accessor :raw

end
