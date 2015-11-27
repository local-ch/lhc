LHC
===

LHC uses [typhoeus](https://github.com/typhoeus/typhoeus) for http communication.

See [LHS](https://github.com/local-ch/LHS), if you are searching for something more **high level** that can query webservices easily and provides easy data access.

## Quick Start Guide

```ruby
  response = LHC.get('http://datastore/v2/feedbacks')
  response.data.items[0]
  response.data.items[0].recommended
  response.body     # String
  response.headers  # Hash
```

## Basic methods

Available are `get`, `post`, `put` & `delete`.

Other methods are available using `LHC.request(options)`.

## A request from scratch

```ruby
  response = LHC.request(url: 'http://local.ch', method: :options)
  response.headers

  response = LHC.request(url: 'http://datastore/v2/feedbacks', method: :get)
  response.data
```

→ [Read more about the request object](docs/request.md)

→ [Read more about the response object](docs/response.md)

## Parallel requests

If you pass an array of requests to `LHC.request`, it will perform those requests in parallel.
You will get back an array of LHC::Response objects.

```ruby
  options = []
  options << { url: 'http://datastore/v2/feedbacks' }
  options << { url: 'http://datastore/v2/content-ads/123/feedbacks' }
  responses = LHC.request(options)
```

## Transfer data through the body

Data that is transfered using the HTTP request body is transfered as you provide it.
Also consider setting the http header for content-type.

```ruby
  LHC.post('http://datastore/v2/feedbacks',
    body: feedback.to_json,
    headers: { 'Content-Type' => 'application/json' }
  )
```

## Configuration

You can configure global endpoints, placeholders and interceptors.

```ruby
  LHC.configure do |c|
    c.placeholder :datastore, 'http://datastore/v2'
    c.endpoint :feedbacks, ':datastore/feedbacks', params: { has_reviews: true }
    c.interceptors = [CacheInterceptor]
  end
```

→ [Read more about configuration](docs/configuration.md)

## URL-Templates

Instead of using concrete urls you can also use url-templates that contain placeholders.
This is especially handy for configuring an endpoint once and generate the url from the params when doing the request.

```ruby
  url = 'http://datastore/v2/feedbacks/:id'
  LHC.config.endpoint(:find_feedback, url, options)
  LHC.get(:find_feedback, params:{ id: 123 })
  # GET http://datastore/v2/feedbacks/123
```

This also works in place without configuring an endpoint.

```ruby
  LHC.get('http://datastore/v2/feedbacks/:id', params:{ id: 123 })
  # GET http://datastore/v2/feedbacks/123
```

If you miss to provide a parameter that is part of the url-template, it will raise an exception.

## Exception handling

Anything but a response code indicating success (2**) throws an exception.

→ [Read more about exceptions](docs/exceptions.md)

## Interceptors

To monitor and manipulate the http communication done with LHC, you can define interceptors.

```ruby
  class TrackingIdInterceptor < LHC::Interceptor

    def before_request(request)
      request.params[:tid] = 123
    end
  end
```

→ [Read more about interceptors](docs/interceptors.md)
