require 'typhoeus'
require 'active_support/core_ext/module'

# The response contains the raw response (typhoeus)
# and provides functionality to access response data.
class LHC::Response
  autoload :Data, 'lhc/response/data'

  attr_accessor :request, :body_replacement, :from_cache

  delegate :effective_url, :code, :headers, :options, :mock, :success?, to: :raw

  # A response is initalized with the underlying raw response (typhoeus in our case)
  # and the associated request.
  def initialize(raw, request, from_cache = false)
    self.request = request
    self.raw = raw
    @from_cache = from_cache
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
    return LHC::Formats::JSON.new if request.nil?
    request.format
  end

  private

  attr_accessor :raw

end
