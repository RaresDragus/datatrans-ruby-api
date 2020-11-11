# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Datatrans::ResponseMapper do
  let(:created_response) do
    OpenStruct.new(
      headers: '"server": "nginx", "content-type": "application/json", "content-length": "44"',
      body: 'OK',
      status: 201
    )
  end

  Datatrans::ResponseMapper::ERRORS.each do |error|
    let(":response_#{error[:name]}") do
      OpenStruct.new(
        headers: '"server": "nginx", "content-type": "application/json", "content-length": "44"',
        body: { error: { code: error[:name], message: error[:name] } }.to_json,
        status: error[:status]
      )
    end
  end

  describe '.build' do
    it 'returns a Datatrans::Result' do
      expect(described_class.build({}, created_response)).to be_a(Datatrans::Result)
    end

    Datatrans::ResponseMapper::ERRORS.each do |error|
      it "returns a Datatrans::#{error[:name].to_s.classify}Error" do
        response = send(":response_#{error[:name]}")
        expect(described_class.build({}, response)).to be_a("Datatrans::#{error[:name].to_s.classify}Error".constantize)
      end

      it "has error code #{error[:name]}" do
        response = send(":response_#{error[:name]}")
        expect(described_class.build({}, response).code).to eq(error[:name].to_s)
      end

      it "has error message #{error[:name]}" do
        response = send(":response_#{error[:name]}")
        expect(described_class.build({}, response).message).to eq(error[:name].to_s)
      end

      it "has error status #{error[:status]}" do
        response = send(":response_#{error[:name]}")
        expect(described_class.build({}, response).status).to eq(error[:status])
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
