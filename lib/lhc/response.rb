require 'typhoeus'

class LHC::Response

  attr_accessor :response

  def initialize(response)
    self.response = response
  end

  # Access response data.
  # Cache parsing.
  def data
    @data ||= JSON.parse(response.body, object_class: OpenStruct)
    @data
  end

  def body
    response.body
  end

  def headers
    response.headers
  end
end
