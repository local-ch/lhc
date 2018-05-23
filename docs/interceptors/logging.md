# Logging Interceptor

The logging interceptor logs all requests done with LHC to the Rails logs.

## Installation

```ruby
  LHC.config.interceptors = [LHC::Logging]

  LHC::Logging.logger = Rails.logger  
```

## What and how it logs

The logging Interceptor logs basic information about the request and the response:

```ruby
LHC.get('http://local.ch')
# Before LHC request<70128730317500> GET http://local.ch at 2018-05-23T07:53:19+02:00 Params={} Headers={\"User-Agent\"=>\"Typhoeus - https://github.com/typhoeus/typhoeus\", \"Expect\"=>\"\"}
# After LHC response for request<70128730317500>: GET http://local.ch at 2018-05-23T07:53:28+02:00 Time=0ms URL=http://local.ch:80/
```

## Configure

You can configure the logger beeing used by the logging interceptor:

```ruby
LHC::Logging.logger = Another::Logger
```
