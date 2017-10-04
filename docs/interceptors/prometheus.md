# Prometheus Interceptor

Logs basic request/response information to prometheus.

```ruby
  require 'prometheus/client'
  LHC::Prometheus.client = Prometheus::Client
  LHC::Prometheus.namespace = 'web_location_app'
  LHC.config.interceptors = [LHC::Prometheus]
```

```ruby
  LHC.get('http://local.ch')
```

- Creates a promethues counter that receives additional meta information for: `:code`, `:success` and `:timeout`.

- Creates a promethues histogram for response times in milliseconds.
