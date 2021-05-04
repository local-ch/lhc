# frozen_string_literal: true

class LHC::Logging < LHC::Interceptor

  include ActiveSupport::Configurable
  config_accessor :logger

  def before_request
    return unless logger

    logger.info(
      [
        'Before LHC request',
        "<#{request.object_id}>",
        request.method.upcase,
        "#{request.url} at #{Time.now.iso8601}",
        "Params=#{request.scrubbed_params}",
        "Headers=#{request.scrubbed_headers}",
        request.source ? "\nCalled from #{request.source}" : nil
      ].compact.join(' ')
    )
  end

  def after_response
    return unless logger

    logger.info(
      [
        'After LHC response for request',
        "<#{request.object_id}>",
        request.method.upcase,
        "#{request.url} at #{Time.now.iso8601}",
        "Time=#{response.time_ms}ms",
        "URL=#{response.effective_url}",
        request.source ? "\nCalled from #{request.source}" : nil
      ].compact.join(' ')
    )
  end
end
