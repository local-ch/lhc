require File.dirname(__FILE__) + '/../error'

class LHC::ServerError < LHC::Error
end

class LHC::InternalServerError < LHC::ServerError
end

class LHC::NotImplemented < LHC::ServerError
end

class LHC::BadGateway < LHC::ServerError
end

class LHC::ServiceUnavailable < LHC::ServerError
end

class LHC::GatewayTimeout < LHC::ServerError
end

class LHC::HttpVersionNotSupported < LHC::ServerError
end

class LHC::InsufficientStorage < LHC::ServerError
end

class LHC::NotExtended < LHC::ServerError
end
