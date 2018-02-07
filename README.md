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

## Formats: like json etc.

You can use any of the basic methods in combination with a format like `json`:

```ruby
LHC.json.get(options)
```

Currently supported formats: `json`

## A request from scratch

```ruby
  response = LHC.request(url: 'http://local.ch', method: :options)
  response.headers

  response = LHC.request(url: 'http://datastore/v2/feedbacks', method: :get)
  response.data
```

→ [Read more about the request object](docs/request.md)

→ [Read more about the response object](docs/response.md)

## Accessing data

The response data can be access with dot-notation and square-bracket notation. You can convert response data to open structs or json (if the response format is json).

```ruby
  response = LHC.request(url: 'http://datastore/entry/1')
  response.data.as_open_struct #<OpenStruct name='local.ch'>
  response.data.as_json # { name: 'local.ch' }
  response.data.name # 'local.ch'
  response.data[:name] # 'local.ch'
```

You can also access response data directly through the response object (with square bracket notation only):

```ruby
  LHC.json.get(url: 'http://datastore/entry/1')[:name]
```

## Parallel requests

If you pass an array of requests to `LHC.request`, it will perform those requests in parallel.
You will get back an array of LHC::Response objects in the same order of the passed requests.

```ruby
  options = []
  options << { url: 'http://datastore/v2/feedbacks' }
  options << { url: 'http://datastore/v2/content-ads/123/feedbacks' }
  responses = LHC.request(options)
```

```ruby
LHC.request([request1, request2, request3])
# returns [response1, response2, response3]
```

## Follow redirects

```ruby
LHC.get('http://local.ch', followlocation: true)
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
    c.endpoint :feedbacks, '{+datastore}/feedbacks', params: { has_reviews: true }
    c.interceptors = [LHC::Caching]
  end
```

→ [Read more about configuration](docs/configuration.md)

## Timeout

Working and configuring timeouts is important, to ensure your app stays alive when services you depend on start to get really slow...

LHC forwards two timeout options directly to typhoeus:

`timeout` (in seconds) - The maximum time in seconds that you allow the libcurl transfer operation to take. Normally, name lookups can take a considerable time and limiting operations to less than a few seconds risk aborting perfectly normal operations. This option may cause libcurl to use the SIGALRM signal to timeout system calls.
`connecttimeout` (in seconds) - It should contain the maximum time in seconds that you allow the connection phase to the server to take. This only limits the connection phase, it has no impact once it has connected. Set to zero to switch to the default built-in connection timeout - 300 seconds. 

```ruby
LHC.get('http://local.ch', timeout: 5, connecttimeout: 1)
```

LHC provides a [timeout interceptor](docs/interceptors/default_timeout.md) that lets you apply default timeout values to all the requests that you are performig in your application.

## URL-Templates

Instead of using concrete urls you can also use url-templates that contain placeholders.
This is especially handy for configuring an endpoint once and generate the url from the params when doing the request.
Since version `7.0` url templates follow the [RFC 6750](https://tools.ietf.org/html/rfc6570).

```ruby
  url = 'http://datastore/v2/feedbacks/{id}'
  LHC.config.endpoint(:find_feedback, url, options)
  LHC.get(:find_feedback, params:{ id: 123 })
  # GET http://datastore/v2/feedbacks/123
```

This also works in place without configuring an endpoint.

```ruby
  LHC.get('http://datastore/v2/feedbacks/{id}', params:{ id: 123 })
  # GET http://datastore/v2/feedbacks/123
```

If you miss to provide a parameter that is part of the url-template, it will raise an exception.

## Exception handling

Anything but a response code indicating success (2**) throws an exception.

→ [Read more about exceptions](docs/exceptions.md)

### Custom error handling

You can provide custom error handlers to handle errors happening during the request.

If a error handler is provided nothing is raised.

If your error handler returns anything else but `nil` it replaces the response body.

```ruby
handler = ->(response){ do_something_with_repsonse; return {name: 'unknown'} }
response = LHC.get('http://something', error_handler: handler)
response.data.name # 'unknown'
```

### Ignore certain errors

As it's discouraged to rescue errors and then don't handle them (ruby styleguide)[https://github.com/bbatsov/ruby-style-guide#dont-hide-exceptions],
but you often want to continue working with `nil`, LHC provides the `ignored_errors` option.

Errors listed in this option will not be raised and will leave the `response.body` and `response.data` to stay `nil`.

```ruby
response = LHC.get('http://something', ignored_errors: [LHC::NotFound])

response.body # nil
response.data # nil
response.error_ignored? # true
response.request.error_ignored? # true
```

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

A set of core interceptors is part of LHC,
like
[Caching](/docs/interceptors/caching.md),
[Monitoring](/docs/interceptors/monitoring.md),
[Authentication](/docs/interceptors/authentication.md),
[Retry](/docs/interceptors/retry.md),
[Rollbar](/docs/interceptors/rollbar.md),
[Prometheus](/docs/interceptors/prometheus.md).

→ [Read more about core interceptors](docs/interceptors.md#core-interceptors)


## License

[GNU Affero General Public License Version 3.](https://www.gnu.org/licenses/agpl-3.0.en.html)
