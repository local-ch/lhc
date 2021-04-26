# frozen_string_literal: true

class LHC::Error < StandardError
  include LHC::FixInvalidEncodingConcern

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

  def self.to_a
    [self]
  end

  def to_s
    return response.to_s unless response.is_a?(LHC::Response)
    request = response.request
    return unless request.is_a?(LHC::Request)

    debug = [] # TODO maybe in the URL
    debug << [request.method, request.url].map { |str| self.class.fix_invalid_encoding(str) }.join(' ')
    debug << "Options: #{request.options}" # TODO HERE
    debug << "Headers: #{request.headers}" # TODO HERE
    debug << "Response Code: #{response.code} (#{response.options[:return_code]})"
    debug << "Response Options: #{response.options}"
    debug << response.body
    debug << _message

    debug.map { |str| self.class.fix_invalid_encoding(str) }.join("\n")
  end
end
