# frozen_string_literal: true

require 'core_ext/hash/deep_transform_values'

class LHC::Rollbar < LHC::Interceptor
  include ActiveSupport::Configurable
  include LHC::FixInvalidEncodingConcern

  def after_response
    return unless Object.const_defined?(:Rollbar)
    return unless report?

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
        headers: request.scrubbed_headers,
        params: request.scrubbed_params
      }
    }.merge additional_params
    begin
      Rollbar.warning("Status: #{response.code} URL: #{request.url}", data)
    rescue JSON::GeneratorError, Encoding::UndefinedConversionError
      sanitized_data = data.deep_transform_values { |value| self.class.fix_invalid_encoding(value) }
      Rollbar.warning("Status: #{response.code} URL: #{request.url}", sanitized_data)
    end
  end

  private

  def report?
    return false if response.success?
    return false if response.request.error_ignored?

    true
  end
end
