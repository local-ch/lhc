require 'singleton'

class LHC::Config
  include Singleton

  def initialize
    @endpoints = {}
    @injections = {}
  end

  def endpoint(name, url, options = {})
    fail 'Endpoint already exists for that name' if @endpoints[name]
    @endpoints[name] = OpenStruct.new({
      url: url,
      options: options
    })
  end

  def endpoints
    @endpoints.dup
  end

  def injection(name, value)
    fail 'Injection already exists for that name' if @injections[name]
    @injections[name] = value
  end

  def injections
    @injections.dup
  end

  def interceptors
    @interceptors || []
  end

  def interceptors=(interceptors)
    fail 'Default interceptors already set and can only be set once' if @interceptors
    @interceptors = interceptors
  end
end
