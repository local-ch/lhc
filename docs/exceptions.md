Exceptions
===

Anything but a 200 response code raises an exception.

```ruby

  LHC.get('localhost') # UnknownError: 0

```

All errors that can occur while using LHC inherit from `LHC::Error`.
They are divided into `LHC::ClientError`, `LHC::ServerError`, `LHC::Timeout` and `LHC::UnkownError`.
