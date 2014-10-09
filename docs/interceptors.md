Interceptors
===

## Quick Start Guide

```
  class TrackingIdInterceptor < LHC::Interceptor

    def before_request(request)
      request.options[:params] ||= {}
      request.options[:params][:tid] = 123
    end
  end
```

## Callbacks

`before_request` is called when the request is prepared and about to be executed.

`after_request` and `before_response` are the same and are called after the request is fired but before the response arrives.

`after_response` is called after the response arrives.

## Priority
