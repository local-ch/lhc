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
