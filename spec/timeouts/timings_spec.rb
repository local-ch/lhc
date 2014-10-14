require 'rails_helper'

describe LHC::Request do

  context 'timeouts' do

    context "when timeout is not a whole number and timeout_ms is not set" do

      let(:options) { {:timeout => 0.1} }

      it "ceils timeout and sets timeout_ms" do
        expect_any_instance_of(Ethon::Easy).to receive(:http_request)
        .with(anything(), anything(), hash_including(:timeout_ms => 100, :timeout => 1))
        .and_call_original
        stub_request(:get, "http://local.ch/")
        LHC.get('http://local.ch', options)
      end
    end

     context "when timeout is not a whole number and timeout_ms is set" do

        let(:options) { {:timeout => 0.1, :timeout_ms => 123} }

        it "ceils timeout and does not change timeout_ms" do
          expect_any_instance_of(Ethon::Easy).to receive(:http_request)
          .with(anything(), anything(), hash_including(:timeout_ms => 123, :timeout => 1))
          .and_call_original
          stub_request(:get, "http://local.ch/")
          LHC.get('http://local.ch', options)
        end
      end

      context "when connecttimeout is not a whole number and connecttimeout_ms is not set" do

        let(:options) { {:connecttimeout => 0.1} }

        it "ceils connecttimeout and sets connecttimeout_ms" do
          expect_any_instance_of(Ethon::Easy).to receive(:http_request)
          .with(anything(), anything(), hash_including(:connecttimeout_ms => 100, :connecttimeout => 1))
          .and_call_original
          stub_request(:get, "http://local.ch/")
          LHC.get('http://local.ch', options)
        end
      end

      context "when connecttimeout is not a whole number and connecttimeout_ms is set" do

        let(:options) { {:connecttimeout => 0.1, :connecttimeout_ms => 123} }

        it "ceils connecttimeout and does not change connecttimeout_ms" do
          expect_any_instance_of(Ethon::Easy).to receive(:http_request)
          .with(anything(), anything(), hash_including(:connecttimeout_ms => 123, :connecttimeout => 1))
          .and_call_original
          stub_request(:get, "http://local.ch/")
          LHC.get('http://local.ch', options)
        end
      end
  end
end
