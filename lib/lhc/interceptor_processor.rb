class LHC::InterceptorProcessor

  cattr_accessor :interceptors
  @@interceptors = []

  attr_accessor :interceptors

  def initialize(target)
    options = target.options if target.is_a? LHC::Request
    options ||= target.request.options if target.is_a? LHC::Response
    self.interceptors = (options[:interceptors] || @@interceptors).map{ |i| i.new }
  end

  def intercept(name, target)
    interceptors.each do |interceptor|
      result = interceptor.send(name, target)
      if result.is_a? LHC::ResponseReturn
        fail 'Response already set from another interceptor' if @response
        request = target.is_a?(LHC::Request) ? target : target.request
        @response = request.response = LHC::Response.new(result.response, request)
      end
    end
  end
end
