# An endpoint is an url that leads to a backend resource.
# It can contain params that have to be injected before the url can be used.
# An endpoint can look like ':datastore/v2/:campaign_id/feedbacks'.
class LHC::Endpoint

  INJECTION = /\:[A-Z,a-z,_,-]+/

  attr_accessor :url

  def initialize(url)
    self.url = url
  end

  # Injects params into url.
  def inject(params)
    url.gsub(INJECTION) do |match|
      injection = if params.is_a? Proc
        params.call(match)
      else
        find_injection(match, params)
      end
      injection || fail("Incomplete injection. Unable to inject #{match.gsub(':', '')}.")
    end
  end

  # Removes keys from provided params hash
  # when they are used for injecting them in the provided endpoint.
  def remove_injected_params!(params)
    params ||= {}
    removed = {}
    url.scan(INJECTION) do |match|
      match = match.gsub(/^\:/, '')
      if injection = find_injection(match, params)
        removed[match.to_sym] = injection
        params.delete(match.to_sym)
      end
    end
    removed
  end

  # Returns all injections used in the url.
  # They are alphabetically sorted.
  def injections
    url.scan(INJECTION).sort
  end

  private

  # Find an injection either in the configuration
  # or in the provided params.
  def find_injection(match, params)
    match = match.gsub(/^\:/, '').to_sym
    LHC.config.injections[match] || params[match]
  end
end
