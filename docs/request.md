Request
===

The request class handles the http request,
implements the interceptor pattern,
loads configured endpoints,
generates urls from url-templates
and raises exceptions for any response code that is not indicating success (2**).

→ [Read more about exceptions](exceptions.md)

```ruby
  request.response #<LHC::Response> the associated response.

  request.options #<Hash> the options used for creating the request.

  request.params # access request params

  request.headers # access request headers

  request.url #<String> URL that is used for doing the request

  request.method #<Symbol> provides the used http-method
```
