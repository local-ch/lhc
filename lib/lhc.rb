# frozen_string_literal: true

require 'typhoeus'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'

module LHC
  autoload :BasicMethodsConcern,
    'lhc/concerns/lhc/basic_methods_concern'
  autoload :ConfigurationConcern,
    'lhc/concerns/lhc/configuration_concern'
  autoload :FormatsConcern,
    'lhc/concerns/lhc/formats_concern'

  include BasicMethodsConcern
  include ConfigurationConcern
  include FormatsConcern

  autoload :Auth,
    'lhc/interceptors/auth'
  autoload :Caching,
    'lhc/interceptors/caching'
  autoload :DefaultTimeout,
    'lhc/interceptors/default_timeout'
  autoload :Logging,
    'lhc/interceptors/logging'
  autoload :Prometheus,
    'lhc/interceptors/prometheus'
  autoload :Retry,
    'lhc/interceptors/retry'
  autoload :Throttle,
    'lhc/interceptors/throttle'

  autoload :Config,
    'lhc/config'
  autoload :Endpoint,
    'lhc/endpoint'

  autoload :Error,
    'lhc/error'
  autoload :ClientError,
    'lhc/errors/client_error'
  autoload :BadRequest,
    'lhc/errors/client_error'
  autoload :Unauthorized,
    'lhc/errors/client_error'
  autoload :PaymentRequired,
    'lhc/errors/client_error'
  autoload :Forbidden,
    'lhc/errors/client_error'
  autoload :Forbidden,
    'lhc/errors/client_error'
  autoload :NotFound,
    'lhc/errors/client_error'
  autoload :MethodNotAllowed,
    'lhc/errors/client_error'
  autoload :NotAcceptable,
    'lhc/errors/client_error'
  autoload :ProxyAuthenticationRequired,
    'lhc/errors/client_error'
  autoload :RequestTimeout,
    'lhc/errors/client_error'
  autoload :Conflict,
    'lhc/errors/client_error'
  autoload :Gone,
    'lhc/errors/client_error'
  autoload :LengthRequired,
    'lhc/errors/client_error'
  autoload :PreconditionFailed,
    'lhc/errors/client_error'
  autoload :RequestEntityTooLarge,
    'lhc/errors/client_error'
  autoload :RequestUriToLong,
    'lhc/errors/client_error'
  autoload :UnsupportedMediaType,
    'lhc/errors/client_error'
  autoload :RequestedRangeNotSatisfiable,
    'lhc/errors/client_error'
  autoload :ExpectationFailed,
    'lhc/errors/client_error'
  autoload :UnprocessableEntity,
    'lhc/errors/client_error'
  autoload :Locked,
    'lhc/errors/client_error'
  autoload :FailedDependency,
    'lhc/errors/client_error'
  autoload :UpgradeRequired,
    'lhc/errors/client_error'
  autoload :ParserError,
    'lhc/errors/parser_error'
  autoload :ServerError,
    'lhc/errors/server_error'
  autoload :InternalServerError,
    'lhc/errors/server_error'
  autoload :NotImplemented,
    'lhc/errors/server_error'
  autoload :BadGateway,
    'lhc/errors/server_error'
  autoload :ServiceUnavailable,
    'lhc/errors/server_error'
  autoload :GatewayTimeout,
    'lhc/errors/server_error'
  autoload :HttpVersionNotSupported,
    'lhc/errors/server_error'
  autoload :InsufficientStorage,
    'lhc/errors/server_error'
  autoload :NotExtended,
    'lhc/errors/server_error'
  autoload :Timeout,
    'lhc/errors/timeout'
  autoload :UnknownError,
    'lhc/errors/unknown_error'

  autoload :Interceptor,
    'lhc/interceptor'
  autoload :Interceptors,
    'lhc/interceptors'
  autoload :Formats,
    'lhc/formats'
  autoload :Format,
    'lhc/format'
  autoload :Monitoring,
    'lhc/interceptors/monitoring'
  autoload :Request,
    'lhc/request'
  autoload :Response,
    'lhc/response'
  autoload :Rollbar,
    'lhc/interceptors/rollbar'
  autoload :Zipkin,
    'lhc/interceptors/zipkin'

  require 'lhc/railtie' if defined?(Rails)
end
