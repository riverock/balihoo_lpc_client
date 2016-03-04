require 'spec_helper'

module BalihooLpcClient
  module Request
    describe Authentication do
      let(:config) do
        Configuration.create do |c|
          c.brand_key = 'foo'
          c.api_key = 'key'
          c.location_key = '1'
          c.user_id = 'foo'
          c.group_id = 'foo'
        end
      end
      let(:connection) { Connection.new(config: config) }

      subject { Authentication.new(connection: connection) }

      describe '.initialize' do
        it 'sets connection for class' do
          expect(subject.connection).to eq connection
        end

        it 'set class base_uri' do
          expect(subject.class.base_uri).to eq config.url
        end
      end

      describe '.authenticate!' do
        let(:params) do
          '?brandKey=foo&apiKey=key&locationKey=1&userId=foo&groupId=foo'
        end

        context 'success' do
          let(:return_opts) do
            {
              status: 200,
              body: '{"clientId":"test_client_id","clientApiKey":"test_client_api_key"}',
              headers: { 'Content-Type' => 'application/json; charset=utf-8' }
            }
          end

          before do
            stub_request(:post, "#{subject.class.base_uri}/genClientAPIKey#{params}")
              .to_return(**return_opts)
          end

          it 'calls api endpoint genClientAPIKey' do
            expect(Authentication).to receive(:post).with('/genClientAPIKey', any_args).and_call_original
            subject.authenticate!
          end

          it 'sets config client_id when authentication successful' do
            subject.authenticate!
            expect(config.client_id).to eq 'test_client_id'
          end

          it 'sets config client_api_key when authentication successful' do
            subject.authenticate!
            expect(config.client_api_key).to eq 'test_client_api_key'
          end

          it 'returns parsed response' do
            expect(subject.authenticate!).to eq JSON.parse(return_opts[:body])
          end
        end

        context 'error' do
          let(:return_opts) do
            {
              status: 401,
              body: 'Could not authenticate',
              headers: { 'Content-Type' => 'text/plain; charset=utf-8' }
            }
          end

          it 'raises AuthenticationError if authentication fails' do
            stub_request(:post, "#{subject.class.base_uri}/genClientAPIKey#{params}")
                .to_return(**return_opts)
            expect { subject.authenticate! }.to raise_error AuthenticationError
          end
        end
      end
    end
  end
end