require 'typhoeus'

# The response contains the raw response (typhoeus)
# and provides functionality to access response data.
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
    @data ||=
      # rubocop:disable Style/IdenticalConditionalBranches
      case format
      when :json
        JSON.parse(raw.body, object_class: OpenStruct)
      else # default is json
        JSON.parse(raw.body, object_class: OpenStruct)
      end
    # rubocop:enable Style/IdenticalConditionalBranches
    @data
  end

  def effective_url
    raw.effective_url
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

  def options
    raw.options
  end

  # Provides response time in ms.
  def time
    (raw.time || 0) * 1000
  end

  def timeout?
    raw.timed_out?
  end

  def success?
    raw.success?
  end

  private

  attr_accessor :raw

  def format
    headers = {}
    headers = request.options.fetch(:headers, {}) if request && request.options
    return :json if headers['Content-Type'] == 'application/json'
  end

end
