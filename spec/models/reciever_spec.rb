require "spec_helper"

describe Receiver do

  context "production environment" do

    let(:payload) { fixture_data('deployment') }
    let!(:data) { JSON.parse(JSON.parse(payload)['payload']) }
    let!(:receiver) { Receiver.new('deployment', '1', payload) }

    it "returns production" do
      expect(receiver.environment).to eq('production')
    end

    it "returns heroku_name" do
      expect(receiver.app_name).to eq(data['config']['heroku_name'])
    end

  end

  context "staging environment" do

    let(:payload) { fixture_data('deployment_staging') }
    let!(:data) { JSON.parse(JSON.parse(payload)['payload']) }
    let!(:receiver) { Receiver.new('deployment', '1', payload) }

    it "returns staging" do
      expect(receiver.environment).to eq('staging')
    end

    it "returns heroku_staging_name" do
      expect(receiver.app_name).to eq(data['config']['heroku_staging_name'])
    end

  end

end
