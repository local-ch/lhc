class LHC::DefaultTimeout < LHC::Interceptor
  include ActiveSupport::Configurable

  config_accessor :timeout, :connecttimeout

  CONNECTTIMEOUT = 2 # seconds
  TIMEOUT = 15 # seconds

  def before_raw_request(request)
    request_options = (request.options || {})
    request_options[:timeout] ||= timeout || TIMEOUT
    request_options[:connecttimeout] ||= connecttimeout || CONNECTTIMEOUT
  end
end
