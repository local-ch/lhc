# Default Timeout Interceptor

Applies default timeout values to all requests made in an application, that uses LHC.

```ruby
  LHC.config.interceptors = [LHC::DefaultTimeout]
```

`timeout` default: 15 seconds
`connecttimeout` default: 1 second

## Overwrite defaults

```ruby
LHC::Timeout.timeout = 5 # seconds
LHC::Timeout.connecttimeout = 2 # second
```
