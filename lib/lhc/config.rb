# frozen_string_literal: true

require 'singleton'

class LHC::Config
  include Singleton

  def initialize
    @endpoints = {}
    @placeholders = {}
  end

  def endpoint(name, url, options = {})
    name = name.to_sym
    raise 'Endpoint already exists for that name' if @endpoints[name]
    @endpoints[name] = LHC::Endpoint.new(url, options)
  end

  def endpoints
    @endpoints.dup
  end

  def placeholder(name, value)
    name = name.to_sym
    raise 'Placeholder already exists for that name' if @placeholders[name]
    @placeholders[name] = value
  end

  def placeholders
    @placeholders.dup
  end

  def interceptors
    (@interceptors || []).dup
  end

  def interceptors=(interceptors)
    raise 'Default interceptors already set and can only be set once' if @interceptors
    @interceptors = interceptors
  end

  def reset
    @endpoints = {}
    @placeholders = {}
    @interceptors = nil
  end
end
