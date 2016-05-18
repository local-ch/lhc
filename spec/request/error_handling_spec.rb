require 'rails_helper'

describe LHC::Request do
  context 'error handling' do
    def to_fail_with(error)
      raise_error(error)
    end

    def expect_status_code(status_code)
      stub_request(:get, "http://something/#{status_code}").to_return(status: status_code)
      expect(
        -> { LHC::Request.new(url: "http://something/#{status_code}") }
      ).to yield
    end

    it 'raises errors for anything but 2XX response codes' do
      expect_status_code(400) { to_fail_with(LHC::BadRequest) }
      expect_status_code(401) { to_fail_with(LHC::Unauthorized) }
      expect_status_code(402) { to_fail_with(LHC::PaymentRequired) }
      expect_status_code(403) { to_fail_with(LHC::Forbidden) }
      expect_status_code(403) { to_fail_with(LHC::Forbidden) }
      expect_status_code(404) { to_fail_with(LHC::NotFound) }
      expect_status_code(405) { to_fail_with(LHC::MethodNotAllowed) }
      expect_status_code(406) { to_fail_with(LHC::NotAcceptable) }
      expect_status_code(407) { to_fail_with(LHC::ProxyAuthenticationRequired) }
      expect_status_code(408) { to_fail_with(LHC::RequestTimeout) }
      expect_status_code(409) { to_fail_with(LHC::Conflict) }
      expect_status_code(410) { to_fail_with(LHC::Gone) }
      expect_status_code(411) { to_fail_with(LHC::LengthRequired) }
      expect_status_code(412) { to_fail_with(LHC::PreconditionFailed) }
      expect_status_code(413) { to_fail_with(LHC::RequestEntityTooLarge) }
      expect_status_code(414) { to_fail_with(LHC::RequestUriToLong) }
      expect_status_code(415) { to_fail_with(LHC::UnsupportedMediaType) }
      expect_status_code(416) { to_fail_with(LHC::RequestedRangeNotSatisfiable) }
      expect_status_code(417) { to_fail_with(LHC::ExpectationFailed) }
      expect_status_code(422) { to_fail_with(LHC::UnprocessableEntity) }
      expect_status_code(423) { to_fail_with(LHC::Locked) }
      expect_status_code(424) { to_fail_with(LHC::FailedDependency) }
      expect_status_code(426) { to_fail_with(LHC::UpgradeRequired) }
      expect_status_code(500) { to_fail_with(LHC::InternalServerError) }
      expect_status_code(501) { to_fail_with(LHC::NotImplemented) }
      expect_status_code(502) { to_fail_with(LHC::BadGateway) }
      expect_status_code(503) { to_fail_with(LHC::ServiceUnavailable) }
      expect_status_code(504) { to_fail_with(LHC::GatewayTimeout) }
      expect_status_code(505) { to_fail_with(LHC::HttpVersionNotSupported) }
      expect_status_code(507) { to_fail_with(LHC::InsufficientStorage) }
      expect_status_code(510) { to_fail_with(LHC::NotExtended) }
    end
  end

  context 'parsing error' do
    before(:each) do
      stub_request(:get, 'http://datastore/v2/feedbacks').to_return(body: 'invalid json')
    end

    it 'requests json and parses response body' do
      expect(->{
        LHC.json.get('http://datastore/v2/feedbacks').data
      }).to raise_error(LHC::ParserError)
    end
  end
end
