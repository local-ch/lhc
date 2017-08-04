# Caching Interceptor

Add the cache interceptor to your basic set of LHC interceptors.

```ruby
  LHC.config.interceptors = [LHC::Caching]
```

You can configure your own cache (default Rails.cache) and logger (default Rails.logger):

```ruby
  LHC::Caching.cache = ActiveSupport::Cache::MemoryStore.new
  LHC::Caching.logger = Logger.new(STDOUT)
```

Caching is not enabled by default, although you added it to your basic set of interceptors.
If you want to have requests served/stored and stored in/from cache, you have to enable it by request.

```ruby
  LHC.get('http://local.ch', cache: true)
```

You can also enable caching when configuring an endpoint in LHS.

```ruby
  class Feedbacks < LHS::Service
    endpoint ':datastore/v2/feedbacks', cache: true
  end
```

Only GET requests are cached by default. If you want to cache any other request method, just configure it:

```ruby
  LHC.get('http://local.ch', cache: true, cached_methods: [:post, :head])
```

## Options

```ruby
  LHC.get('http://local.ch', cache: true, cache_expires_in: 1.day, cache_race_condition_ttl: 15.seconds, preemptively_clean_filestore: true)
```

`cache_expires_in` - lets the cache expires every X seconds.

`cache_key` - Set the key that is used for caching by using the option. Every key is prefixed with `LHC_CACHE(v1): `.

`cache_race_condition_ttl` - very useful in situations where a cache entry is used very frequently and is under heavy load.
If a cache expires and due to heavy load several different processes will try to read data natively and then they all will try to write to cache.
To avoid that case the first process to find an expired cache entry will bump the cache expiration time by the value set in `cache_race_condition_ttl`.

`preemptively_clean_filestore` -  setting this option will prompt deletion of expired cache entries, if the cache backend is `ActiveSupport::Cache::FileStore`. This is useful
for very shortlived caches, such as LHS' [Request Cycle Cache](https://github.com/local-ch/lhs#request-cycle-cache)

## Testing

Add to your spec_helper.rb:

```ruby
  require 'lhc/test/cache_helper.rb'
```

This will initialize a MemoryStore cache for LHC::Caching interceptor and resets the cache before every test.
