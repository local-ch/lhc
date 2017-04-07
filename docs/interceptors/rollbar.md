# Rollbar Interceptor

Forward errors to rollbar when exceptions occur during http requests.

```ruby
  LHC.config.interceptors = [LHC::Rollbar]
```

```ruby
  LHC.get('http://local.ch')
```

If it raises, it forwards the request and response object to rollbar, which contain all necessary data.

## Forward additional parameters

```ruby
  LHC.get('http://local.ch', rollbar: { tracking_key: 'this particular request' })
```
