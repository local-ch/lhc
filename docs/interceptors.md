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

`before_request(request)` is called when the request is prepared and about to be executed.

`after_request(request)` is called after request was fired.

`before_response(request)` is called before response arrives, so directly after `after_request` was called.

`after_response(response)` is called after the response arrives.

## Priority
