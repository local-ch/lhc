class LHC::InterceptorProcessor

  include Opt

  cattr_accessor :interceptors
  @@interceptors = []

  attr_accessor :skip_others
  attr_reader :response

  def intercept(name, target)
    @@interceptors.each do |interceptor|
      next if opted_out?(interceptor, target) || skip_others
      result = interceptor.send(name, target)
      self.skip_others = true if result.is_a? LHC::ResponseInterrupt
      self.response = result.response if result.is_a? LHC::ResponseReturn
    end
  end

  def response=(response)
    fail 'Response already set from another interceptor' if @response
    @response = response
  end

  def self.add(interceptor)
    @@interceptors.push(interceptor)
  end
end
