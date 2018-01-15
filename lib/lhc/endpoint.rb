require 'addressable/template'

# An endpoint is an url that leads to a backend resource.
# The url can also be an url-template (https://tools.ietf.org/html/rfc6570).
class LHC::Endpoint
  attr_accessor :url, :options

  def initialize(url, options = nil)
    self.url = url
    self.options = options
  end

  def uri
    @uri ||= Addressable::Template.new(url)
  end

  def compile(params)
    context = LHC.config.placeholders.deep_dup
    context.merge!(params) if params.is_a?(Hash)
    expanded = uri.partial_expand(context)

    if expanded.variables.empty?
      expanded.pattern
    else
      fail("Compilation incomplete. Unable to find value for #{expanded.variables.join(', ')}.")
    end
  end

  # Endpoint options are immutable
  def options
    @options.deep_dup
  end

  # Removes keys from provided params hash
  # when they are used for interpolation.
  def remove_interpolated_params!(params)
    params ||= {}
    removed = params.slice(*placeholders)
    params.except!(*placeholders)

    removed
  end

  # Returns all placeholders found in the url-template.
  # They are alphabetically sorted.
  def placeholders
    uri.variables.sort.map(&:to_sym)
  end

  # Compares a concrete url with a template
  # Returns true if concrete url is covered by the template
  # Example: {+datastore}/contracts/{id} == http://local.ch/contracts/1
  def match?(url)
    return true if url == uri.pattern
    match_data = match_data(url)
    return false if match_data.nil?

    match_data.values.all? { |value| valid_value?(value) }
  end

  # Extracts the values from url and
  # creates params according to template
  def values_as_params(url)
    match_data = match_data(url)
    return if match_data.nil?
    Hash[match_data.variables.map(&:to_sym).zip(match_data.values)]
  end

  # Checks if the name has a match in the current context
  def find_value(name, mapping)
    context = LHC.config.placeholders.deep_dup
    context.merge!(mapping)

    context[name]
  end

  # Compares a concrete url with a template
  # Returns true if concrete url is covered by the template
  # Example: {+datastore}/contracts/{id} == http://local.ch/contracts/1
  def self.match?(url, template)
    new(template).match?(url)
  end

  # Returns all placeholders found in the url-template.
  # They are alphabetically sorted.
  def self.placeholders(template)
    new(template).placeholders
  end

  # Extracts the values from url and
  # creates params according to template
  def self.values_as_params(template, url)
    fail("#{url} does not match the template: #{template}") if !match?(url, template)
    new(template).values_as_params(url)
  end

  private

  # Ensure there are no false positives in the template matching
  def valid_value?(value)
    value.match(%{https?:/$}).nil? &&
      value.match(/.*\.json/).nil?
  end

  def match_data(url)
    parsed = URI.parse(url)
    parsed.query = parsed.fragment = nil

    uri.match(parsed)
  rescue URI::InvalidURIError
    nil
  end
end
