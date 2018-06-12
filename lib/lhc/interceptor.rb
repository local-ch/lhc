class LHC::Interceptor

  attr_reader :request

  def initialize(request)
    @request = request
  end

  def response
    @request.response
  end

  def before_raw_request
  end

  def before_request
  end

  def after_request
  end

  def before_response
  end

  def after_response
  end

  # Prevent Interceptors from beeing duplicated!
  # Their classes have flag-character.
  # When duplicated you can't check for their class name anymore:
  # e.g. options.deep_dup[:interceptors].include?(LHC::Caching) # false
  def self.dup
    self
  end
end
