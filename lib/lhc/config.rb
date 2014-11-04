require 'singleton'

class LHC::Config
  include Singleton

  def initialize
    @endpoints = {}
    @placeholders = {}
  end

  def endpoint(name, url, options = {})
    name = name.to_sym
    fail 'Endpoint already exists for that name' if @endpoints[name]
    @endpoints[name] = OpenStruct.new({
      url: url,
      options: options
    })
  end

  def endpoints
    @endpoints.dup
  end

  def placeholder(name, value)
    name = name.to_sym
    fail 'Placeholder already exists for that name' if @placeholders[name]
    @placeholders[name] = value
  end

  def placeholders
    @placeholders.dup
  end

  def interceptors
    (@interceptors || []).dup
  end

  def interceptors=(interceptors)
    fail 'Default interceptors already set and can only be set once' if @interceptors
    @interceptors = interceptors
  end
end
