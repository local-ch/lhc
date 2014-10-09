Interceptors
===

## Quick Start Guide

Interceptors are registered globally as soon as you intherit from LHC::Interceptor.

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

## Opt-out

Interceptors are mainly global. You can opt-out any global interceptor by using the `opt_out` keyword when passing options to a request.

```
  class GeneralStatsInterceptor < LHC::Interceptor
  end
  
  LHS::Request.new({opt_out: :general_stats_interceptor}) # is not calling the GeneralStatsInterceptor
```

## Opt-in

You can also define Interceptors that are just called when opt-in for specific requests by using the `opt_in` keyword when passing options to a request.

To do so you have to define the Interceptor to be `opt_in`.

```
  class SpecialStatsInterceptor < LHC::Interceptor
    opt_in
  end
  
  LHS::Request.new({opt_in: :special_stats_interceptor}) # is calling the SpecialStatsInterceptor
```
