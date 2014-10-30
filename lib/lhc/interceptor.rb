class LHC::Interceptor

  def before_request(request); end
  def after_request(request); end

  def before_response(request); end
  def after_response(response); end

  def return_response(response)
    LHC::ResponseReturn.new(response)
  end

end
