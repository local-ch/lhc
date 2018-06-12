class LHC::Logging < LHC::Interceptor

  include ActiveSupport::Configurable
  config_accessor :logger

  def before_request
    return unless logger
    logger.info(
      "Before LHC request<#{request.object_id}> #{request.method.upcase} #{request.url} at #{Time.now} Params=#{request.params} Headers=#{request.headers}"
    )
  end

  def after_response
    return unless logger
    logger.info(
      "After LHC response for request<#{request.object_id}> #{request.method.upcase} #{request.url} at #{Time.now} Time=#{response.time_ms}ms URL=#{response.effective_url}"
    )
  end
end
