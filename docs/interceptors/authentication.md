# Authentication Interceptor

Add the auth interceptor to your basic set of LHC interceptors.

```ruby
  LHC.config.interceptors = [LHC::Auth]
```

## Bearer Authentication

```ruby
  LHC.get('http://local.ch', auth: { bearer: -> { access_token } })
```

Adds the following header to the request:
```
  'Authorization': 'Bearer 123456'
```

Assuming the method `access_token` responds on runtime of the request with `123456`.

## Basic Authentication

```ruby
  LHC.get('http://local.ch', auth: { basic: { username: 'steve', password: 'can' } })
```

Adds the following header to the request:
```
  'Authorization': 'Basic c3RldmU6Y2Fu'
```

Which is the base64 encoded credentials "username:password".

# Reauthenticate

The current implementation can only offer reauthenticate for _client access tokens_. For this to work the following has to be given:

* You have configured and implemented `LHC::Auth.refresh_client_token = -> { TokenRefreshUtil.client_access_token(true) }` which when called will force a refresh of the token and return the new value. It is also expected that this implementation will handle invalidating caches if necessary.
* Your interceptors contain `LHC::Auth` and `LHC::Retry`, whereas `LHC::Retry` comes _after_ `LHC::Auth` in the chain.

## Bearer Authentication with client access token

Reauthentication will be initiated if:

* setup is correct
* `response.success?` is false and an `LHC::Unauthorized` was observed
* reauthentication wasn't already attempted once

If this is the case, this happens:

* refresh the client token, by calling `refresh_client_token`
* the authentication header will be updated with the new token
* `LHC::Retry` will be triggered by adding `retry: { max: 1 }` to the request options
