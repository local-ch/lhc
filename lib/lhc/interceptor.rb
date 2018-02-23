class LHC::Interceptor

  def before_raw_request(request); end

  def before_request(request); end

  def after_request(request); end

  def before_response(request); end

  def after_response(response); end

  # Prevent Interceptors from beeing duplicated!
  # Their classes have flag-character.
  # When duplicated you can't check for their class name anymore:
  # e.g. options.deep_dup[:interceptors].include?(LHC::Caching) # false
  def self.dup
    self
  end
end
