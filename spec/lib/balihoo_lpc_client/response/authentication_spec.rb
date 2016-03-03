require 'spec_helper'

module BalihooLpcClient
  module Response
    describe Authentication do
      subject { described_class.new({'clientId' => 'clientId', 'clientApiKey' => 'clientApiKey'}) }

      it 'has property clientId' do
        expect(described_class.properties).to include 'clientId'
      end

      it 'has property clientApiKey' do
        expect(described_class.properties).to include 'clientApiKey'
      end

      describe ".client_id" do
        it 'is an alias of clientId' do
          expect(subject.client_id).to eq subject.clientId
        end
      end

      describe ".client_api_key" do
        it 'is an alias of clientApiKey' do
          expect(subject.client_api_key).to eq subject.clientApiKey
        end
      end
    end
  end
end
