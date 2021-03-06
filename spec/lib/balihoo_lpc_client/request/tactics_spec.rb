require 'spec_helper'

module BalihooLpcClient
  module Request
    describe Tactics do
      let(:config) do
        Configuration.create do |c|
          c.brand_key = 'foo'
          c.api_key = 'key'
          c.location_key = '1'
          c.user_id = 'foo'
          c.group_id = 'foo'
          c.client_id = 'id' #simulating that authenticate has been called
          c.client_api_key = 'key' #simulating that authenticate has been called
        end
      end
      let(:api) { Api.new(config: config) }

      subject { described_class.new(api: api, params: {}, campaign_id: '1') }

      describe '.initialize' do
        it 'sets api for class' do
          expect(subject.api).to eq api
        end

        it 'sets params for class' do
          expect(subject.params).to eq({})
        end

        it 'sets campaign_id for class' do
          expect(subject.campaign_id).to eq '1'
        end
      end

      describe '.fetch' do
        let(:params) do
          arr = subject.params.map do |k, v|
            "#{k}=#{v}"
          end
          arr.any? ? "?#{arr.join('&')}" : ''
        end

        let(:request_headers) do
          {
            'X-ClientId' => config.client_id,
            'X-ClientApiKey' => config.client_api_key
          }
        end

        context 'success' do
          let(:return_opts) do
            {
              status: 200,
              body: '{"campaignId":1,"tactics":[{"id":1,"title":"Title","start":"2015-09-21","end":"2016-09-21","channel":"Paid Search","description":"","creative":"http://example.com"}]}',
              headers: { 'Content-Type' => 'application/json; charset=utf-8' }
            }
          end

          before do
            stub_request(:get, "#{subject.class.base_uri}/campaign/#{subject.campaign_id}/tactics#{params}")
              .with(:headers => request_headers)
              .to_return(**return_opts)
          end

          it 'calls api endpoint campaigns' do
            expect(described_class).to receive(:get).with("/campaign/#{subject.campaign_id}/tactics", any_args).and_call_original
            subject.fetch
          end

          it 'returns an array of Response::Tactic objects' do
            returned = JSON.parse(return_opts[:body])['tactics']
            expect(subject.fetch).to eq returned.map { |t| Response::Tactic.new(t) }
          end

          context 'with params' do
            subject { described_class.new(api: api, params: { locations: [1], from: '2016-01-01', to: '2016-01-31' }, campaign_id: 1) }

            let(:params) do
              arr = subject.send(:sanitized_params).map do |k, v|
                "#{k}=#{v}"
              end
              arr.any? ? "?#{arr.join('&')}" : ''
            end

            context 'location key missing' do
              let(:config) do
                Configuration.create do |c|
                  c.brand_key = 'foo'
                  c.api_key = 'key'
                  c.user_id = 'foo'
                  c.group_id = 'foo'
                  c.client_id = 'id' #simulating that authenticate has been called
                  c.client_api_key = 'key' #simulating that authenticate has been called
                end
              end

              it 'passes params to api call' do
                expect(described_class).to receive(:get).with("/campaign/#{subject.campaign_id}/tactics", { headers: request_headers, query: subject.send(:sanitized_params) }).and_call_original
                subject.fetch
              end

              context 'requesting single location' do
                it 'returns an array of Response::Tactic objects' do
                  returned = JSON.parse(return_opts[:body])['tactics']
                  expect(subject.fetch).to eq returned.map { |o| Response::Tactic.new(o) }
                end
              end

              context 'requesting multiple locations' do
                subject { described_class.new(api: api, params: { locations: [1,2], from: '2016-01-01', to: '2016-01-31' }, campaign_id: 1) }

                let(:return_opts) do
                  {
                    status: 200,
                    body: '{"1":[{"id":1,"title":"Title","start":"2015-09-21","end":"2016-09-21","channel":"Paid Search","description":"","creative":"http://example.com"}],"2":[{"id":1,"title":"Title","start":"2015-09-21","end":"2016-09-21","channel":"Paid Search","description":"","creative":"http://example.com"}]}',
                    headers: { 'Content-Type' => 'application/json; charset=utf-8' }
                  }
                end

                it 'returns a hash with location as key and values of Response::Campaign objects' do
                  returned = JSON.parse return_opts[:body]
                  returned = returned.inject({}) do |h, pair|
                    h.merge({ pair[0] => pair[1].map { |v| Response::Tactic.new(v) } })
                  end
                  expect(subject.fetch).to eq returned
                end
              end
            end

            context 'location_key present' do
              it 'removes locations if location_key is present' do
                expect(described_class).to receive(:get).with("/campaign/#{subject.campaign_id}/tactics", { headers: request_headers, query: subject.send(:sanitized_params) }).and_call_original
                subject.fetch
              end
            end
          end
        end

        context 'error' do
          let(:request_headers) do
            {
              'X-ClientId' => config.client_id,
              'X-ClientApiKey' => config.client_api_key
            }
          end

          before do
            stub_request(:get, "#{subject.class.base_uri}/campaign/#{subject.campaign_id}/tactics#{params}")
              .with(headers: request_headers).to_return(**return_opts)
          end

          context 'session expired' do
            let(:return_opts) do
              {
                status: 401,
                body: 'Client api session has expired',
                headers: { 'Content-Type' => 'text/plain; charset=utf-8' }
              }
            end

            it 'raises ApiSessionExpiredError if session expired' do
              expect { subject.fetch }.to raise_error ApiSessionExpiredError
            end
          end

          context 'other errors' do
            let(:return_opts) do
              {
                status: 401,
                body: 'Some other error.',
                headers: { 'Content-Type' => 'text/plain; charset=utf-8' }
              }
            end

            it 'raises ApiResponseError for all other errors' do
              expect { subject.fetch }.to raise_error ApiResponseError
            end
          end
        end
      end
    end
  end
end
