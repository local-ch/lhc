Interceptors
===

## Quick Start Guide

```ruby
  class TrackingIdInterceptor < LHC::Interceptor

    def before_request(request)
      request.params[:tid] = 123
    end
  end
```

```ruby
  LHC.config.interceptors = [TrackingIdInterceptor] # global list of default interceptors
```

```ruby
  LHC.request({url: 'http://local.ch', interceptors: []}) # no interceptor for this request
```

## Core Interceptors

There are some interceptors that are part of LHC already, that cover some basic usecases:
like [Caching](/docs/interceptors/caching.md), [Monitoring](/docs/interceptors/monitoring.md), [Authentication](/docs/interceptors/authentication.md), [Rollbar](/docs/interceptors/rollbar.md).

## Callbacks

`before_raw_request(request)` is called before the raw typhoeus request is prepared/created.

`before_request(request)` is called when the request is prepared and about to be executed.

`after_request(request)` is called after request was started.

`before_response(request)` is called when response started to arrive.

`after_response(response)` is called after the response arrived completely.

→ [Read more about the request object](request.md)

→ [Read more about the response object](response.md)

## Global default interceptors

Set the list of global default interceptors.
The global default interceptors are processed in the order you provide them.

```ruby
  LHC.config.interceptors = [CachingInterceptor, MonitorInterceptor, TrackingIdInterceptor]
```

You can only set the list of global interceptors once and you cannot alter them later.

## Interceptors on request level

You can override the global default interceptors on request level:

```ruby
  interceptors = LHC.config.interceptors
  interceptors -= [CachingInterceptor] # remove caching
  interceptors += [RetryInterceptor] # add retry
  LHC.request({url: 'http://local.ch', retry: 2, interceptors: interceptors})
```

## Provide Response

Inside an interceptor, you are able to provide a response, rather then doing a real request.
This is usefull for implementing an interceptor for caching.

```ruby
class LHC::Cache < LHC::Interceptor

  def before_request(request)
    cached_response = Rails.cache.fetch(request.url)
    return LHC::Response.new(cached_response) if cached_response
  end
end
```

Take care that having more than one interceptor trying to return a response will cause an exception.
You can access the request.response to identify if a response was already provided by another interceptor.

```ruby
  class RemoteCacheInterceptor < LHC::Interceptor

    def before_request(request)
      return unless request.response.nil?
      return LHC::Response.new(remote_cache)
    end
  end
```
