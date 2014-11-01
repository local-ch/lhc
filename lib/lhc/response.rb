require 'typhoeus'

# A abstraction of a response.
# In this case we abstract the thphoues response.
class LHC::Response

  attr_accessor :request

  # A response is initalized with the underlying raw response (typhoeus in our case)
  # and the associated request.
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

  def body
    raw.body
  end

  def code
    raw.code
  end

  def headers
    raw.headers
  end

  # Provides response time in ms.
  def time
    (raw.time || 0) * 1000
  end

  private

  attr_accessor :raw

end
