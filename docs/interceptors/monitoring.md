# Monitoring Interceptor

The monitoring interceptor reports all requests done with LHC to a given StatsD instance.

## Installation

```ruby
  LHC.config.interceptors = [LHC::Monitoring]
```

You also have to configure statsd in order to have the monitoring interceptor report.

```ruby
  LHC::Monitoring.statsd = <your-instance-of-statsd>
```

### Environment

By default, the monitoring interceptor uses Rails.env to determine the environment. In case you want to configure that, use:

```ruby
LHC::Monitoring.env = ENV['DEPLOYMENT_TYPE'] || Rails.env
```

## What it tracks

It tracks request attempts with `before_request` and `after_request` (counts).

In case your workers/processes are getting killed due limited time constraints, 
you are able to detect deltas with relying on "before_request", and "after_request" counts:

```ruby
  "lhc.<app_name>.<env>.<host>.<http_method>.before_request", 1
  "lhc.<app_name>.<env>.<host>.<http_method>.after_request", 1
```

In case of a successful response it reports the response code with a count and the response time with a gauge value.

```ruby
  LHC.get('http://local.ch')

  "lhc.<app_name>.<env>.<host>.<http_method>.count", 1
  "lhc.<app_name>.<env>.<host>.<http_method>.200", 1
  "lhc.<app_name>.<env>.<host>.<http_method>.time", 43
```

Timeouts are also reported:

```ruby
  "lhc.<app_name>.<env>.<host>.<http_method>.timeout", 1
```

All the dots in the host are getting replaced with underscore (_), because dot is the default separator in graphite.


## Configure

It is possible to set the key for Monitoring Interceptor on per request basis:

```ruby
  LHC.get('http://local.ch', monitoring_key: 'local_website')

  "local_website.count", 1
  "local_website.200", 1
  "local_website.time", 43
```

If you use this approach you need to add all namespaces (app, environment etc.) to the key on your own.
