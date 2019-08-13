# frozen_string_literal: true

class LHC::Error < StandardError
  attr_accessor :response, :_message

  def self.map
    {
      400 => LHC::BadRequest,
      401 => LHC::Unauthorized,
      402 => LHC::PaymentRequired,
      403 => LHC::Forbidden,
      404 => LHC::NotFound,
      405 => LHC::MethodNotAllowed,
      406 => LHC::NotAcceptable,
      407 => LHC::ProxyAuthenticationRequired,
      408 => LHC::RequestTimeout,
      409 => LHC::Conflict,
      410 => LHC::Gone,
      411 => LHC::LengthRequired,
      412 => LHC::PreconditionFailed,
      413 => LHC::RequestEntityTooLarge,
      414 => LHC::RequestUriToLong,
      415 => LHC::UnsupportedMediaType,
      416 => LHC::RequestedRangeNotSatisfiable,
      417 => LHC::ExpectationFailed,
      422 => LHC::UnprocessableEntity,
      423 => LHC::Locked,
      424 => LHC::FailedDependency,
      426 => LHC::UpgradeRequired,

      500 => LHC::InternalServerError,
      501 => LHC::NotImplemented,
      502 => LHC::BadGateway,
      503 => LHC::ServiceUnavailable,
      504 => LHC::GatewayTimeout,
      505 => LHC::HttpVersionNotSupported,
      507 => LHC::InsufficientStorage,
      510 => LHC::NotExtended
    }
  end

  def self.find(response)
    return LHC::Timeout if response.timeout?

    status_code = response.code.to_s[0..2].to_i
    error = map[status_code]
    error ||= LHC::UnknownError
    error
  end

  def self.dup
    self
  end

  def initialize(message, response)
    super(message)
    self._message = message
    self.response = response
  end

  def to_s
    return response if response.is_a?(String)

    request = response.request
    debug = []
    debug << [request.method, request.url].map { |str| fix_invalid_encoding(str) }.join(' ')
    debug << "Options: #{request.options}"
    debug << "Headers: #{request.headers}"
    debug << "Response Code: #{response.code} (#{response.options[:return_code]})"
    debug << "Response Options: #{response.options}"
    debug << response.body
    debug << _message
    debug.map { |str| fix_invalid_encoding(str) }.join("\n")
  end

  private

  # fix strings that contain non-UTF8 encoding in a forceful way
  # should none of the fix-attempts be successful,
  # an empty string is returned instead
  def fix_invalid_encoding(string)
    return string unless string.is_a?(String)

    result = string.dup

    # we assume it's ISO-8859-1 first
    if !result.valid_encoding? || !utf8?(result)
      result.encode!('UTF-8', 'ISO-8859-1', invalid: :replace, undef: :replace, replace: '')
    end

    # if it's still an issue, try with BINARY
    if !result.valid_encoding? || !utf8?(result)
      result.encode!('UTF-8', 'BINARY', invalid: :replace, undef: :replace, replace: '')
    end

    # if its STILL an issue, return an empty string :(
    if !result.valid_encoding? || !utf8?(result)
      result = ""
    end

    result
  end

  def utf8?(string)
    string.encoding == Encoding::UTF_8
  end
end
