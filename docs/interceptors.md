Interceptors
===

## Quick Start Guide

Interceptors are registered globally as soon as you intherit from LHC::Interceptor.

```ruby
  class TrackingIdInterceptor < LHC::Interceptor

    def before_request(request)
      request.add_param(tid: 123)
    end
  end
```

## Callbacks

`before_request(request)` is called when the request is prepared and about to be executed.

`after_request(request)` is called after request was fired.

`before_response(request)` is called before response arrives, so directly after `after_request` was called.

`after_response(response)` is called after the response arrives.

## Priority

Interceptors will be processed FIFO. So take care that you define them in the order you want to have them executed globally later.

## Opt-out

Interceptors are mainly global. You can opt-out any global interceptor by using the `opt_out` keyword when passing options to a request.

```ruby
  class GeneralStatsInterceptor < LHC::Interceptor
  end

  LHC.request({opt_out: :general_stats_interceptor, url: 'http://local.ch'}) # is not calling the GeneralStatsInterceptor
```

## Opt-in

You can also define Interceptors that are just called when opt-in for specific requests by using the `opt_in` keyword when passing options to a request.

To do so you have to define the Interceptor to be `opt_in`.

```ruby
  class SpecialStatsInterceptor < LHC::Interceptor
    opt_in
  end

  LHC.request({opt_in: :special_stats_interceptor, url: 'http://local.ch'}) # is calling the SpecialStatsInterceptor
```

## Inject Response

Sometimes you want to inject another response in the http communication (e.g. caching). LHC provides the functionality to return a response inside an interceptor.
You can return a response either immediately (so all other interceptors are skiped) using `return_response!`
or you can provide a response that is returned after all interceptors run with `return_response`.

```ruby
class CacheInterceptor < LHC::Interceptor

  def before_request(request)
    cached_response = Rails.cache.fetch(request.url)
    return_response!(cached_response) if cached_response
  end
end
```
