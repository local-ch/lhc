require 'rails_helper'

describe LHC::Error do

  def response(code)
    LHC::Response.new(OpenStruct.new({code: code}), nil)
  end

  context 'find' do

    it 'finds error class by status code' do
      expect(LHC::Error.find(response('400'))).to eq LHC::BadRequest
      expect(LHC::Error.find(response('401'))).to eq LHC::Unauthorized
      expect(LHC::Error.find(response('402'))).to eq LHC::PaymentRequired
      expect(LHC::Error.find(response('403'))).to eq LHC::Forbidden
      expect(LHC::Error.find(response('403'))).to eq LHC::Forbidden
      expect(LHC::Error.find(response('404'))).to eq LHC::NotFound
      expect(LHC::Error.find(response('405'))).to eq LHC::MethodNotAllowed
      expect(LHC::Error.find(response('406'))).to eq LHC::NotAcceptable
      expect(LHC::Error.find(response('407'))).to eq LHC::ProxyAuthenticationRequired
      expect(LHC::Error.find(response('408'))).to eq LHC::RequestTimeout
      expect(LHC::Error.find(response('409'))).to eq LHC::Conflict
      expect(LHC::Error.find(response('410'))).to eq LHC::Gone
      expect(LHC::Error.find(response('411'))).to eq LHC::LengthRequired
      expect(LHC::Error.find(response('412'))).to eq LHC::PreconditionFailed
      expect(LHC::Error.find(response('413'))).to eq LHC::RequestEntityTooLarge
      expect(LHC::Error.find(response('414'))).to eq LHC::RequestUriToLong
      expect(LHC::Error.find(response('415'))).to eq LHC::UnsupportedMediaType
      expect(LHC::Error.find(response('416'))).to eq LHC::RequestedRangeNotSatisfiable
      expect(LHC::Error.find(response('417'))).to eq LHC::ExpectationFailed
      expect(LHC::Error.find(response('422'))).to eq LHC::UnprocessableEntity
      expect(LHC::Error.find(response('423'))).to eq LHC::Locked
      expect(LHC::Error.find(response('424'))).to eq LHC::FailedDependency
      expect(LHC::Error.find(response('426'))).to eq LHC::UpgradeRequired
      expect(LHC::Error.find(response('500'))).to eq LHC::InternalServerError
      expect(LHC::Error.find(response('501'))).to eq LHC::NotImplemented
      expect(LHC::Error.find(response('502'))).to eq LHC::BadGateway
      expect(LHC::Error.find(response('503'))).to eq LHC::ServiceUnavailable
      expect(LHC::Error.find(response('504'))).to eq LHC::GatewayTimeout
      expect(LHC::Error.find(response('505'))).to eq LHC::HttpVersionNotSupported
      expect(LHC::Error.find(response('507'))).to eq LHC::InsufficientStorage
      expect(LHC::Error.find(response('510'))).to eq LHC::NotExtended
    end

    it 'finds error class also by extended status codes' do
      expect(LHC::Error.find(response('40001'))).to eq LHC::BadRequest
      expect(LHC::Error.find(response('50002'))).to eq LHC::InternalServerError
    end

    it 'returns UnknownError if no specific error was found' do
      expect(LHC::Error.find(response('0'))).to eq LHC::UnknownError
      expect(LHC::Error.find(response(''))).to eq LHC::UnknownError
      expect(LHC::Error.find(response('600'))).to eq LHC::UnknownError
    end
  end
end
