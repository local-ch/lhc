class LHC::Interceptor

  include Opt

  def before_request(request); end
  def after_request(request); end

  def before_response(request); end
  def after_response(response); end

  def return_response(response)
    LHC::ResponseReturn.new(response)
  end

  def return_response!(response)
    LHC::ResponseInterrupt.new(response)
  end

  private

  def self.inherited(interceptor)
    LHC::InterceptorProcessor.add(interceptor.new)
    super
  end
end
