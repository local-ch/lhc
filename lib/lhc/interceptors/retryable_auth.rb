class LHC::RetryableAuth < LHC::Interceptor
  attr_accessor :retries, :current_retry

  class << self
    attr_accessor :max
  end

  def before_request
    options = request.options[:auth] || {}
    authenticate!(request, options)
  end

  def after_response
    binding.pry
    return if response.success? || LHC::Error.find(response) != LHC::Unauthorized
    options = response.request.options[:auth] || {}
    token = options[:bearer]
    # refresh the token
    token = token.call(true) if token.is_a?(Proc)
    set_authorization_header response.request, "Bearer #{token}"
    # set retry on the request
    response.request.options[:retry] = true
  end

  private

  def authenticate!(request, options)
    if options[:bearer]
      bearer_authentication!(request, options)
    elsif options[:basic]
      basic_authentication!(request, options)
    end
  end

  def basic_authentication!(request, options)
    auth = options[:basic]
    credentials = "#{auth[:username]}:#{auth[:password]}"
    set_authorization_header request, "Basic #{Base64.encode64(credentials).chomp}"
  end

  def bearer_authentication!(request, options)
    token = options[:bearer]
    token = token.call if token.is_a?(Proc)
    set_authorization_header request, "Bearer #{token}"
  end

  def set_authorization_header(request, value)
    request.headers['Authorization'] = value
  end
end

LHC::RetryableAuth.max = 3



# class LHC::Retry < LHC::Interceptor
#   attr_accessor :retries, :current_retry

#   class << self
#     attr_accessor :max
#   end

#   def after_response
#     response.request.options[:retries] ||= 0
#     return unless retry?(response.request)
#     response.request.options[:retries] += 1
#     current_retry = response.request.options[:retries]
#     begin
#       response.request.run!
#     rescue LHC::Error
#       return
#     end
#     response.request.response if current_retry == response.request.options[:retries]
#   end

#   private

#   def retry?(request)
#     return false if request.response.success?
#     return false unless request.options.dig(:retry)
#     request.options[:retries] < max(request)
#   end

#   def max(request)
#     options(request).is_a?(Hash) ? options(request).fetch(:max, LHC::Retry.max) : LHC::Retry.max
#   end

#   def options(request)
#     @options ||= request.options.dig(:retry)
#   end
# end

# LHC::Retry.max = 3
