Configuration
===

## Configure LHC on initialization

If you want to configure LHC on initialization (like in a Rails initializer, `environment.rb` or `application.rb`), you could run into the problem that certain configurations can only be set once.
You can use `LHC.configure` to prevent the initialization problem.
Take care that you only use `LHC.configure` once, because it is actually reseting previously made configurations and applies the new once.

```ruby

  LHC.configure do |c|
    c.placeholder :datastore, 'http://datastore/v2'
    c.endpoint :feedbacks, '{+datastore}/feedbacks'
    c.interceptors = [CachingInterceptor, MonitorInterceptor, TrackingIdInterceptor]
  end

```

## Endpoints

You can configure endpoints, for later use, by giving them a name, an url and some parameters (optional).

```ruby
  url = 'http://datastore/v2/feedbacks'
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
  LHC.config.placeholder(:datastore, 'http://datastore/v2')
  options = { params: { has_reviews: true } }
  LHC.config.endpoint(:feedbacks, '{+datastore}/feedbacks', options)
  LHC.get(:feedbacks)
```

## Interceptors

To enable interceptors you have to configure LHC's interceptors for http communication.
The global default interceptors are processed in the order you provide them.

```ruby
  LHC.config.interceptors = [CachingInterceptor, MonitorInterceptor, TrackingIdInterceptor]
```

You can only set the list of global interceptors once and you can not alter it after you set it.
