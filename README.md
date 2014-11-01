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

## Basic methods

Available HTTP methods are `get`, `post`, `put` & `delete`.

Other methods are available using `LHC.request(options)`.

## Make a request from scratch

```ruby
  response = LHC.request(url: 'http://local.ch', method: :options)
  response.headers

  response = LHC.request(url: 'http://datastore.lb-service/v2/feedbacks', method: :get)
  response.data
```

→ [Read more about the request object](docs/request.md)

→ [Read more about the response object](docs/response.md)

## Transfer data through the body

Data that is transfered using the HTTP request body is transfered as you provide it.

If you want to send it as json, you should transfer it to json first.

```ruby
  LHC.post('http://datastore.lb-service/v2/feedbacks', body: feedback.to_json)
```

## Configuration

You can configure endpoints, injections and interceptors.

```ruby
  LHC.config.injection(:datastore, 'http://datastore.lb-service/v2')
  LHC.config.endpoint(:feedbacks, ':datastore/feedbacks', params: { has_reviews: true })
  LHC.config.interceptors = [CacheInterceptor]
```

→ [Read more about configuration](docs/configuration.md)

## URL-Patterns

Instead of providing a concrete URL you can just provide the pattern of a URL containing placeholders.
This is especially handy for configuring endpoints once and get generated urls when doing the requests automaticaly.

```ruby
  url = 'http://datastore.lb-service/v2/feedbacks'
  options = { params: { has_reviews: true } }
  LHC.config.endpoint(:feedbacks, url, options)
  LHC.get(:feedbacks)
```

This also works if you dont configure endpoints but just want to have it working for explicit requests:

```ruby
  LHC.get('http://datastore-stg.lb-service:8080/v2/feedbacks/:id', params:{id: 123})
```

If you miss to provide an parameter that is part of the pattern, an exception will occur.

## Interceptors

```ruby
  class TrackingIdInterceptor < LHC::Interceptor

    def before_request(request)
      request.merge_params!(tid: 123)
    end
  end
```

→ [Read more about interceptors](docs/interceptors.md)
