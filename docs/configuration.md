Configuration
===

## Endpoints

You can configure endpoints for later use by name.

```ruby
  url = 'http://datastore.lb-service/v2/feedbacks'
  options = { params: { has_reviews: true } }
  LHC.config.endpoint(:feedbacks, url, options)
  LHC.get(:feedbacks)
```

Explicit request options are overriding configured options.

```ruby
  LHC.get(:feedbacks, params: { has_reviews: false }) # Overrides configured params
```

## Placeholders

You can configure global placeholder, that are used when generate url from url-patterns.

```ruby
  LHC.config.placeholder(:datastore, 'http://datastore.lb-service/v2')
  options = { params: { has_reviews: true } }
  LHC.config.endpoint(:feedbacks, url, options)
  LHC.get(:feedbacks)
```
