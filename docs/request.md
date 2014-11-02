Request
===

The request class handles the http request,
implements the interceptor pattern,
loads configured endpoints,
generates urls from url-patterns
and raises exceptions for any response status but 200.

→ [Read more about exceptions](exceptions.md)

```ruby
  request.response #<LHC::Response> the associated response.

  request.options #<Hash> the options used for creating the request.

  request.merge_params(params) # used for adding params to the request (e.g. inside an interceptor)

  request.url #<String> URL that is used for doing the request

  request.method #<Symbol> provides the used http-method
```
