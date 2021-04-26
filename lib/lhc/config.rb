# frozen_string_literal: true

require 'singleton'

class LHC::Config
  include Singleton

  def initialize
    @endpoints = {}
    @placeholders = {}
    @scrubs = default_scrubs
  end

  def endpoint(name, url, options = {})
    name = name.to_sym
    raise 'Endpoint already exists for that name' if @endpoints[name]
    @endpoints[name] = LHC::Endpoint.new(url, options)
  end

  def endpoints
    @endpoints.dup
  end

  def scrubs
    @scrubs
  end

  def scrubs=(scrubs)
    @scrubs = scrubs
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

  # TODO also make something like this
  def interceptors=(interceptors)
    raise 'Default interceptors already set and can only be set once' if @interceptors
    @interceptors = interceptors
  end

  def default_scrubs
    {
      auth: [:bearer, :basic],
      params: [],
      headers: [],
      body: ['password', 'password_confirmation']
    }
  end

  def reset
    @endpoints = {}
    @placeholders = {}
    @interceptors = nil
    @scrubs = default_scrubs
  end
end
