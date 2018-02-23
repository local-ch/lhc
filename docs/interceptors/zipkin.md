# Zipkin Distrubted Tracing

Zipkin is a distributed tracing system. It helps gather timing data needed to troubleshoot latency problems in microservice architectures [Zipkin Distributed Tracing](https://zipkin.io/).

Add the zipkin interceptor to your basic set of LHC interceptors.

```ruby
  LHC.config.interceptors = [LHC::ZipkinDistributedTracing]
```

The following configuration is happening in the application that wants to run this interceptor:

1. Add `gem 'zipkin-tracer'` to your Gemfile.
2. Add the necessary Rack middleware and configuration in the <environment>.rb file(s)

```
config.middleware.use ZipkinTracer::RackHandler, {
  service_name: 'service-name', # name your service will be known as in zipkin
  service_port: 80, # the port information that is sent along the trace
  json_api_host: 'http://zipkin-collector.preprod-local.ch', # the zipkin endpoint
  sample_rate: 1 # sample rate, where 1 = 100% of all requests, and 0.1 is 10% of all requests
}
```

## Testing

Add to your spec_helper.rb:

```ruby
  require 'lhc/test/zipkin_mock.rb'
```

This will initialize a mock implementation of zipkin.
