class LHC::Error < StandardError

  attr_accessor :response

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

  def initialize(message, response)
    super(message)
    self.response = response
  end

  def to_s
    request = response.request
    debug = []
    debug << "#{request.method} #{request.url}"
    debug << "Params: #{request.options}"
    debug << "Response Code: #{response.code}"
    debug << response.body
    debug.join("\n")
  end
end
