require 'rails_helper'

describe LHC::Error do
  def response(code)
    LHC::Response.new(OpenStruct.new(code: code), nil)
  end

  context 'find' do
    it 'finds error class by status code' do
      expect(described_class.find(response('400'))).to eq LHC::BadRequest
      expect(described_class.find(response('401'))).to eq LHC::Unauthorized
      expect(described_class.find(response('402'))).to eq LHC::PaymentRequired
      expect(described_class.find(response('403'))).to eq LHC::Forbidden
      expect(described_class.find(response('403'))).to eq LHC::Forbidden
      expect(described_class.find(response('404'))).to eq LHC::NotFound
      expect(described_class.find(response('405'))).to eq LHC::MethodNotAllowed
      expect(described_class.find(response('406'))).to eq LHC::NotAcceptable
      expect(described_class.find(response('407'))).to eq LHC::ProxyAuthenticationRequired
      expect(described_class.find(response('408'))).to eq LHC::RequestTimeout
      expect(described_class.find(response('409'))).to eq LHC::Conflict
      expect(described_class.find(response('410'))).to eq LHC::Gone
      expect(described_class.find(response('411'))).to eq LHC::LengthRequired
      expect(described_class.find(response('412'))).to eq LHC::PreconditionFailed
      expect(described_class.find(response('413'))).to eq LHC::RequestEntityTooLarge
      expect(described_class.find(response('414'))).to eq LHC::RequestUriToLong
      expect(described_class.find(response('415'))).to eq LHC::UnsupportedMediaType
      expect(described_class.find(response('416'))).to eq LHC::RequestedRangeNotSatisfiable
      expect(described_class.find(response('417'))).to eq LHC::ExpectationFailed
      expect(described_class.find(response('422'))).to eq LHC::UnprocessableEntity
      expect(described_class.find(response('423'))).to eq LHC::Locked
      expect(described_class.find(response('424'))).to eq LHC::FailedDependency
      expect(described_class.find(response('426'))).to eq LHC::UpgradeRequired
      expect(described_class.find(response('500'))).to eq LHC::InternalServerError
      expect(described_class.find(response('501'))).to eq LHC::NotImplemented
      expect(described_class.find(response('502'))).to eq LHC::BadGateway
      expect(described_class.find(response('503'))).to eq LHC::ServiceUnavailable
      expect(described_class.find(response('504'))).to eq LHC::GatewayTimeout
      expect(described_class.find(response('505'))).to eq LHC::HttpVersionNotSupported
      expect(described_class.find(response('507'))).to eq LHC::InsufficientStorage
      expect(described_class.find(response('510'))).to eq LHC::NotExtended
    end

    it 'finds error class also by extended status codes' do
      expect(described_class.find(response('40001'))).to eq LHC::BadRequest
      expect(described_class.find(response('50002'))).to eq LHC::InternalServerError
    end

    it 'returns UnknownError if no specific error was found' do
      expect(described_class.find(response('0'))).to eq LHC::UnknownError
      expect(described_class.find(response(''))).to eq LHC::UnknownError
      expect(described_class.find(response('600'))).to eq LHC::UnknownError
    end
  end
end
