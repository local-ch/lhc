Configuration
===

## Endpoints

You can configure endpoints by name to later run http-requests using the configured endpoint by name.

```ruby
  url = 'http://datastore.lb-service/v2/feedbacks'
  options = { params: { has_reviews: true } }
  LHC.config.endpoint(:feedbacks, url, options)
  LHC.get(:feedbacks)
```

Explicit request options are overriding configured options:

```ruby
  LHC.get(:feedbacks, params: { has_reviews: false })
```
This would override configured params for has_reviews.

## Injections

You can configure global injections, that are used when injecting values in url-patterns.

```ruby
  url = ':datastore/feedbacks'
  options = { params: { has_reviews: true } }
  LHC.config.endpoint(:feedbacks, url, options)
  LHC.config.injection(:datastore, 'http://datastore.lb-service/v2')
  LHC.get(:feedbacks)
```
