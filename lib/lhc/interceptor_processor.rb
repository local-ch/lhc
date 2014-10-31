class LHC::InterceptorProcessor

  cattr_accessor :interceptors
  @@interceptors = []

  attr_accessor :interceptors
  attr_reader :response

  def initialize(target)
    options = target.options if target.is_a? LHC::Request
    options ||= target.request.options if target.is_a? LHC::Response
    self.interceptors = (options[:interceptors] || @@interceptors).map{ |i| i.new }
  end

  def intercept(name, target)
    interceptors.each do |interceptor|
      result = interceptor.send(name, target)
      self.response = result.response if result.is_a? LHC::ResponseReturn
    end
  end

  def response=(response)
    fail 'Response already set from another interceptor' if @response
    @response = response
  end

end
