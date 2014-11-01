Response
===

```ruby
  response.data #<OpenStruct> in case response body contains parsable JSON.
  response.data.something.nested

  response.body #<String>

  response.code #<Fixnum>

  response.headers #<Hash>

  response.time #<Fixnum> Provides response time in ms.
```
