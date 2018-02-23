class LHC::Rollbar < LHC::Interceptor
  include ActiveSupport::Configurable

  def after_response
    return unless Object.const_defined?('Rollbar')
    return if response.success?
    request = response.request
    additional_params = request.options.fetch(:rollbar, {})
    data = {
      response: {
        body: response.body,
        code: response.code,
        headers: response.headers,
        time: response.time,
        timeout?: response.timeout?
      },
      request: {
        url: request.url,
        method: request.method,
        headers: request.headers,
        params: request.params
      }
    }.merge additional_params
    Rollbar.warning("Status: #{response.code} URL: #{request.url}", data)
  end
end
