# Default Timeout Interceptor

Applies default timeout values to all requests made in an application, that uses LHC.

```ruby
  LHC.config.interceptors = [LHC::DefaultTimeout]
```

`timeout` default: 15 seconds
`connecttimeout` default: 2 second

## Overwrite defaults

```ruby
LHC::DefaultTimeout.timeout = 5 # seconds
LHC::DefaultTimeout.connecttimeout = 3 # seconds
```
