class LHC::Auth < LHC::Interceptor
  include ActiveSupport::Configurable
  config_accessor :refresh_client_token, :retry_on

  def before_request
    options = request.options[:auth] || {}
    authenticate!(request, options)
  end

  def after_response
    binding.pry
    return unless handle_refresh_and_retry?(response)
    # refresh the token
    token = refresh_client_token_option(response.request).call
    set_authorization_header response.request, "Bearer #{token}"
    # set retry on the request
    response.request.options[:retry] = true
    # do not try again
    options = request.options[:auth] || {}
    options[:was_retried_auth] = true
    response.request.options[:auth] = options
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

  def handle_refresh_and_retry?(response)
    options = request.options[:auth] || {}

    has_bearer_header = response.request.headers['Authorization'] =~ /^Bearer [0-9a-f-]+$/i
    retry_on = retry_on_option(response.request)
    refresh_client_token = refresh_client_token_option(response.request)

    !response.success? && has_bearer_header && !options[:was_retried_auth] && LHC::Error.find(response) == retry_on && refresh_client_token && refresh_client_token.is_a?(Proc)
  end

  def refresh_client_token_option(request)
    @refresh_client_token_option ||= request.options.dig(:auth, :refresh_client_token) || refresh_client_token
  end

  def retry_on_option(request)
    @retry_on_option ||= request.options.dig(:auth, :retry_on) || retry_on
  end
end
