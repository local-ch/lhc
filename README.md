LHC
===

LHC uses [typhoeus](https://github.com/typhoeus/typhoeus) for http requests.

Get a look at [LHS](https://github.com/local-ch/LHS), if you are searching for something more **high level** that can query webservices easily and provides easy data access.

## Quick Start Guide

```ruby
  response = LHC.get('http://datastore.lb-service/v2/feedbacks')
  response.data.items[0]
  response.data.items[0].recommended
  response.body     # String
  response.headers  # Hash
```

## Available shorthand methods

Available HTTP methods are `get`, `post`, `put` & `delete`.

Other methods are available using `LHC.request(options)`.

## Make a request from scratch

```ruby
  response = LHC.request(url: 'http://local.ch', method: :options)
  response.headers

  response = LHC.request(url: 'http://datastore.lb-service/v2/feedbacks', method: :get)
  response.data
```

## Transfer data through the body

Data that is transfered using the HTTP request body is transfered as you provied it.

If you want to send it as json, you should transfer it to json first.

```ruby
  LHC.post('http://datastore.lb-service/v2/feedbacks', body: feedback.to_json)
```

## Configure endpoints

You can configure endpoints and then use HTTP methods targeting that endpoint by name.

```ruby
  endpoint = 'http://datastore.lb-service/v2/feedbacks'
  options = { params: { has_reviews: true } }
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
