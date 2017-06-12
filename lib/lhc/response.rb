require 'typhoeus'

# The response contains the raw response (typhoeus)
# and provides functionality to access response data.
class LHC::Response

  attr_accessor :request, :body_replacement

  delegate :effective_url, :code, :headers, :options, :mock, :success?, to: :raw

  # A response is initalized with the underlying raw response (typhoeus in our case)
  # and the associated request.
  def initialize(raw, request)
    self.request = request
    self.raw = raw
  end

  def data
    @data ||= LHC::Response::Data.new(self)
  end

  def [](key)
    data[key]
  end

  def body
    body_replacement || raw.body
  end

  # Provides response time in ms.
  def time
    (raw.time || 0) * 1000
  end

  def timeout?
    raw.timed_out?
  end

  def format
    return JsonFormat.new if request.nil?
    request.format
  end

  private

  attr_accessor :raw

end
