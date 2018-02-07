class LHC::Retry < LHC::Interceptor
  attr_accessor :retries, :current_retry

  class << self
    attr_accessor :max
  end

  def after_response(response)
    response.request.options[:retries] ||= 0
    return unless retry?(response.request)
    response.request.options[:retries] += 1
    current_retry = response.request.options[:retries]
    begin
      response.request.run!
    rescue LHC::Error
      return
    end
    response.request.response if current_retry == response.request.options[:retries]
  end

  private

  def retry?(request)
    return false if request.response.success?
    return false unless request.options.dig(:retry)
    request.options[:retries] < max(request)
  end

  def max(request)
    options(request).is_a?(Hash) ? options(request).fetch(:max, LHC::Retry.max) : LHC::Retry.max
  end

  def options(request)
    @options ||= request.options.dig(:retry)
  end
end

LHC::Retry.max = 3