LHC
===

LHC uses [typhoeus](https://github.com/typhoeus/typhoeus) for http requests.

## Quick Start Guide

```ruby
  response = LHC.get('http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks')
  response.data.items[0]
  response.data.items[0].recommended
  response.body     # String
  response.headers  # Hash
```

## Available shorthand methods

Available HTTP methods are `get`, `post`, `put` & `delete` other methods are available using `LHC.request(options)` directly.

## Make a request from scratch

```ruby
  response = LHC.request(url: 'http://local.ch', method: :options)
  response.headers

  response = LHC.request(url: 'http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks', method: :get)
  response.data
```

## Transfer data through the body

Data that is transfered using the HTTP request body is transfered as you provied it.
If you want to send it as json you should transfer it to be json first.

```ruby
  LHC.post('http://datastore.lb-service/v2/feedbacks', body: feedback.to_json)
```

## Configure endpoints

You can configure endpoints and then use HTTP methods targeting that endpoint by name.

```ruby
  endpoint = 'http://:datastore/v2/feedbacks'
  options = { params: { datastore: 'datastore.lb-service' } }
  LHC.set(:feedbacks, endpoint, options)
  LHC.get(:feedbacks)
```

## Interceptors

```ruby
  class TrackingIdInterceptor < LHC::Interceptor

    def before_request(request)
      request.add_param(tid: 123)
    end
  end
```

→ [Read more about interceptors](docs/interceptors.md)
