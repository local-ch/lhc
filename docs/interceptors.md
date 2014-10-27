Interceptors
===

## Quick Start Guide

Interceptors are registered globally as soon as you intherit from LHC::Interceptor.

```ruby
  class TrackingId < LHC::Interceptor

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

## Excluding Interceptors

Interceptors are mainly global. You can opt-out any global interceptor by using the `without` keyword when passing options to a request.

```ruby
  class GeneralStats < LHC::Interceptor
  end

  LHC.request({without: :general_stats, url: 'http://local.ch'}) # is not calling the GeneralStats interceptor
```

## Opt-in

You can also define Interceptors that are only called for specific requests by using the `with` keyword when passing options to a request.

To do so you have to define the Interceptor to be `optional`.

```ruby
  class SpecialStats < LHC::Interceptor
    optional
  end

  LHC.request({with: :special_stats, url: 'http://local.ch'}) # is calling the SpecialStats interceptor
```
