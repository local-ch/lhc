# An endpoint is an url that leads to a backend resource.
# The url can also be an url-template.
class LHC::Endpoint

  PLACEHOLDER = /\:[A-Z,a-z,_,-]+/

  attr_accessor :url, :options

  def initialize(url, options = nil)
    self.url = url
    self.options = options
  end

  def compile(params)
    url.gsub(PLACEHOLDER) do |match|
      replacement = if params.is_a? Proc
        params.call(match)
      else
        find_value(match, params)
      end
      replacement || fail("Compilation incomplete. Unable to find value for #{match.gsub(':', '')}.")
    end
  end

  # Removes keys from provided params hash
  # when they are used for interpolation.
  def remove_interpolated_params!(params)
    params ||= {}
    removed = {}
    url.scan(PLACEHOLDER) do |match|
      match = match.gsub(/^\:/, '')
      if value = find_value(match, params)
        removed[match.to_sym] = value
        params.delete(match.to_sym)
      end
    end
    removed
  end

  # Returns all placeholders found in the url-template.
  # They are alphabetically sorted.
  def placeholders
    LHC::Endpoint.placeholders(url)
  end

  # Find a value for a placeholder either in the configuration
  # or in the provided params.
  def find_value(match, params)
    params ||= {}
    match = match.gsub(/^\:/, '').to_sym
    params[match] || LHC.config.placeholders[match]
  end

  # Compares a concrete url with a template
  # Returns true if concrete url is covered by the template
  def self.match?(url, template)
    regexp = template
    LHC::Endpoint.placeholders(template).each do |placeholder|
      regexp = regexp.gsub(placeholder, '.*')
    end
    url.match(Regexp.new("^#{regexp}$"))
  end

  # Returns all placeholders found in the url-template.
  # They are alphabetically sorted.
  def self.placeholders(template)
    template.scan(PLACEHOLDER).sort
  end

  # Extracts the values from url and
  # creates params according to template
  def self.values_as_params(template, url)
    params = {}
    regexp = template
    LHC::Endpoint.placeholders(template).each do |placeholder|
      name = placeholder.gsub(":", '')
      regexp = regexp.gsub(placeholder, "(?<#{name}>.*)")
    end
    matchdata = url.match(Regexp.new("^#{regexp}$"))
    LHC::Endpoint.placeholders(template).each do |placeholder|
      name = placeholder.gsub(':', '')
      params[name.to_sym] = matchdata[name]
    end
    params
  end
end
