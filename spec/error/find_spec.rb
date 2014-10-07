require 'rails_helper'

describe LHC::Error do

  context 'find' do

    it 'finds error class by status code' do
      expect(LHC::Error.find('400')).to eq BadRequest
      expect(LHC::Error.find('401')).to eq Unauthorized
      expect(LHC::Error.find('402')).to eq PaymentRequired
      expect(LHC::Error.find('403')).to eq Forbidden
      expect(LHC::Error.find('403')).to eq Forbidden
      expect(LHC::Error.find('404')).to eq NotFound
      expect(LHC::Error.find('405')).to eq MethodNotAllowed
      expect(LHC::Error.find('406')).to eq NotAcceptable
      expect(LHC::Error.find('407')).to eq ProxyAuthenticationRequired
      expect(LHC::Error.find('408')).to eq RequestTimeout
      expect(LHC::Error.find('409')).to eq Conflict
      expect(LHC::Error.find('410')).to eq Gone
      expect(LHC::Error.find('411')).to eq LengthRequired
      expect(LHC::Error.find('412')).to eq PreconditionFailed
      expect(LHC::Error.find('413')).to eq RequestEntityTooLarge
      expect(LHC::Error.find('414')).to eq RequestUriToLong
      expect(LHC::Error.find('415')).to eq UnsupportedMediaType
      expect(LHC::Error.find('416')).to eq RequestedRangeNotSatisfiable
      expect(LHC::Error.find('417')).to eq ExpectationFailed
      expect(LHC::Error.find('422')).to eq UnprocessableEntity
      expect(LHC::Error.find('423')).to eq Locked
      expect(LHC::Error.find('424')).to eq FailedDependency
      expect(LHC::Error.find('426')).to eq UpgradeRequired
      expect(LHC::Error.find('500')).to eq InternalServerError
      expect(LHC::Error.find('501')).to eq NotImplemented
      expect(LHC::Error.find('502')).to eq BadGateway
      expect(LHC::Error.find('503')).to eq ServiceUnavailable
      expect(LHC::Error.find('504')).to eq GatewayTimeout
      expect(LHC::Error.find('505')).to eq HttpVersionNotSupported
      expect(LHC::Error.find('507')).to eq InsufficientStorage
      expect(LHC::Error.find('510')).to eq NotExtended
    end

    it 'finds error class also by exteded status code' do
      expect(LHC::Error.find('40001')).to eq BadRequest
      expect(LHC::Error.find('50002')).to eq InternalServerError
    end

    it 'returns UnknownError if not specific error was found' do
      expect(LHC::Error.find('0')).to eq UnknownError
      expect(LHC::Error.find('')).to eq UnknownError
      expect(LHC::Error.find('600')).to eq UnknownError
    end
  end
end
