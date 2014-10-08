LHC
===

## Quick Start Guide

```
  response = LHC.get('http://datastore-stg.lb-service.sunrise.intra.local.ch/v2/feedbacks', has_reviews: true)
  response.data.items[0]
  response.data.items[0].recommended
  response.body     # String
  response.headers  # Hash
```

## Available methods

Available HTTP methods are `get`, `post`, `put`, `delete`, `options`.

## Configure endpoints

You can configure endpoints and then use HTTP methods targeting that endpoint by name:

```
  endpoint = 'http://:datastore/v2/feedbacks'
  params = { datastore: 'datastore.lb-service' }
  LHC::Config.set(:feedbacks, endpoint, params)
  LHC.get(:feedbacks)
```
