Configuration
===

## Endpoints

You can configure endpoints, for later use, by giving them a name, an url and some parameters (optional).

```ruby
  url = 'http://datastore.lb-service/v2/feedbacks'
  options = { params: { has_reviews: true } }
  LHC.config.endpoint(:feedbacks, url, options)
  LHC.get(:feedbacks)
```

Explicit request options override configured options.

```ruby
  LHC.get(:feedbacks, params: { has_reviews: false }) # Overrides configured params
```

## Placeholders

You can configure global placeholders, that are used when generating urls from url-templates.

```ruby
  LHC.config.placeholder(:datastore, 'http://datastore.lb-service/v2')
  options = { params: { has_reviews: true } }
  LHC.config.endpoint(:feedbacks, url, options)
  LHC.get(:feedbacks)
```

## Interceptors

To enable interceptors you have to configure LHC's interceptors for http communication.
The global default interceptors are processed in the order you provide them.

```ruby
  LHC.config.interceptors = [CachingInterceptor, MonitorInterceptor, TrackingIdInterceptor]
```

You can only set the list of global interceptors once and you can not alter it after you set it.
