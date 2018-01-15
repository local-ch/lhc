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
    context = LHC.config.placeholders
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

  def placeholders
    uri.variables.sort.map(&:to_sym)
  end

  def match?(url)
    match_data = uri.match(url)
    return false if match_data.nil?

    match_data.values.all? { |value| valid_value?(value) }
  end

  def values_as_params(url)
    match_data = uri.match(url)
    Hash[match_data.variables.map(&:to_sym).zip(match_data.values)]
  end

  # Compares a concrete url with a template
  # Returns true if concrete url is covered by the template
  # Example: :datastore/contracts/:id == http://local.ch/contracts/1
  def self.match?(url, template)
    parsed = URI.parse(url)
    parsed.query = parsed.fragment = nil
    new(template).match?(parsed)
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
end
