# frozen_string_literal: true

# Handles interceptions during the lifecycle of a request
# Represents all active interceptors for a request/response.
class LHC::Interceptors

  attr_accessor :all

  # Intitalizes and determines if global or local interceptors are used
  def initialize(request)
    self.all = (request.options[:interceptors] || LHC.config.interceptors).map do |interceptor|
      interceptor.new(request)
    end
  end

  # Forwards messages to interceptors and handles provided responses.
  def intercept(name)
    all.each do |interceptor|
      result = interceptor.send(name)
      if result.is_a? LHC::Response
        raise 'Response already set from another interceptor' if @response
        @response = interceptor.request.response = result
      end
    end
  end
end
