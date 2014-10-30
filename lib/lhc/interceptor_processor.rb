class LHC::InterceptorProcessor

  cattr_accessor :interceptors
  @@interceptors = []

  attr_accessor :interceptors
  attr_reader :response

  def initialize
    self.interceptors = @@interceptors.map{|i| i.new }
  end

  def intercept(name, target)
    interceptors.each do |interceptor|
      next unless should_process?(interceptor, target)
      result = interceptor.send(name, target)
      self.response = result.response if result.is_a? LHC::ResponseReturn
    end
  end

  def response=(response)
    fail 'Response already set from another interceptor' if @response
    @response = response
  end

  private

  def should_process?(interceptor, target)
    options = target.options if target.is_a? LHC::Request
    options ||= target.request.options if target.is_a? LHC::Response
    interceptors = options[:interceptors] || LHC.default_interceptors
    interceptors.include? interceptor.class
  end

end
