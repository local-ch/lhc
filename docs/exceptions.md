Exceptions
===

Anything but a response code indicating success (2**) raises an exception.

```ruby

  LHC.get('localhost') # UnknownError: 0
  LHC.get('http://localhost:3000') # LHC::Timeout: 0

```

You can access the response object that was causing the error.

```ruby
LHC.get('local.ch')
rescue => e
  e.response #<LHC:Response>
  e.response.code # 403
```

All errors that can occur during http-requests inherit from `LHC::Error`.
They are divided into `LHC::ClientError`, `LHC::ServerError`, `LHC::Timeout` and `LHC::UnkownError` and mapped arcording to the response status code.

```ruby
400 => LHC::BadRequest
401 => LHC::Unauthorized
402 => LHC::PaymentRequired
403 => LHC::Forbidden
403 => LHC::Forbidden
404 => LHC::NotFound
405 => LHC::MethodNotAllowed
406 => LHC::NotAcceptable
407 => LHC::ProxyAuthenticationRequired
408 => LHC::RequestTimeout
409 => LHC::Conflict
410 => LHC::Gone
411 => LHC::LengthRequired
412 => LHC::PreconditionFailed
413 => LHC::RequestEntityTooLarge
414 => LHC::RequestUriToLong
415 => LHC::UnsupportedMediaType
416 => LHC::RequestedRangeNotSatisfiable
417 => LHC::ExpectationFailed
422 => LHC::UnprocessableEntity
423 => LHC::Locked
424 => LHC::FailedDependency
426 => LHC::UpgradeRequired

500 => LHC::InternalServerError
501 => LHC::NotImplemented
502 => LHC::BadGateway
503 => LHC::ServiceUnavailable
504 => LHC::GatewayTimeout
505 => LHC::HttpVersionNotSupported
507 => LHC::InsufficientStorage
510 => LHC::NotExtended

timeout? => LHC::Timeout

anything_else => LHC::UnknownError
```
