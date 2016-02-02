# Handles interceptions during the lifecycle of a request
class LHC::InterceptorProcessor

  attr_accessor :interceptors

  # Intitalizes the processor and determines if global or local interceptors are used
  def initialize(target)
    options = target.options if target.is_a? LHC::Request
    options ||= target.request.options if target.is_a? LHC::Response
    self.interceptors = (options[:interceptors] || LHC.config.interceptors).map { |i| i.new }
  end

  # Forwards messages to interceptors and handles provided responses.
  def intercept(name, target)
    interceptors.each do |interceptor|
      result = interceptor.send(name, target)
      if result.is_a? LHC::Response
        fail 'Response already set from another interceptor' if @response
        request = target.is_a?(LHC::Request) ? target : target.request
        @response = request.response = result
      end
    end
  end
end
