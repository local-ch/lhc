require File.dirname(__FILE__) + '/../error'

class LHC::ClientError < LHC::Error
end

class LHC::BadRequest < LHC::ClientError
end

class LHC::Unauthorized < LHC::ClientError
end

class LHC::PaymentRequired < LHC::ClientError
end

class LHC::Forbidden < LHC::ClientError
end

class LHC::Forbidden < LHC::ClientError
end

class LHC::NotFound < LHC::ClientError
end

class LHC::MethodNotAllowed < LHC::ClientError
end

class LHC::NotAcceptable < LHC::ClientError
end

class LHC::ProxyAuthenticationRequired < LHC::ClientError
end

class LHC::RequestTimeout < LHC::ClientError
end

class LHC::Conflict < LHC::ClientError
end

class LHC::Gone < LHC::ClientError
end

class LHC::LengthRequired < LHC::ClientError
end

class LHC::PreconditionFailed < LHC::ClientError
end

class LHC::RequestEntityTooLarge < LHC::ClientError
end

class LHC::RequestUriToLong < LHC::ClientError
end

class LHC::UnsupportedMediaType < LHC::ClientError
end

class LHC::RequestedRangeNotSatisfiable < LHC::ClientError
end

class LHC::ExpectationFailed < LHC::ClientError
end

class LHC::UnprocessableEntity < LHC::ClientError
end

class LHC::Locked < LHC::ClientError
end

class LHC::FailedDependency < LHC::ClientError
end

class LHC::UpgradeRequired < LHC::ClientError
end
