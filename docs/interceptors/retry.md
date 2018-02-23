# Retry Interceptor

If you enable the retry interceptor, you can have LHC retry requests for you:

```ruby
  LHC.config.interceptors = [LHC::Retry]
  response = LHC.get('http://local.ch', retry: true)
```

It will try to retry the request up to 3 times (default) internally, before it passes the last response back, or raises an error for the last response.

Consider, that all other interceptors will run for every single retry.

## Limit the amount of retries while making the request

```ruby
  LHC.get('http://local.ch', retry: { max: 1 })
```

## Change the default maximum of retries of the retry interceptor

```ruby
  LHC::Retry.max = 3
```
