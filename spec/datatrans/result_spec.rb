# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Datatrans::Result do
  let(:subject) do
    described_class.new(
      headers: '"server": "nginx", "content-type": "application/json", "content-length": "44", '\
               '"connection": "keep-alive", "strict-transport-security": "max-age=15768000; includeSubdomains", '\
               '"x-xss-protection": "1; mode=block", '\
               '"location": "https://pay.sandbox.datatrans.com/v1/start/201110082708737796", '\
               '"correlation-id": "2eff0e4e-c9c2-439a-8cc7-8d05908b18ab"',
      response: { transactionId: '201110082708737796' }.to_json,
      status: 201
    )
  end

  it { is_expected.to respond_to(:headers) }
  it { is_expected.to respond_to(:response) }
  it { is_expected.to respond_to(:status) }

  it 'does not raise error if the response is only a string (eg: "OK")' do
    expect do
      described_class.new(
        headers: '"server": "nginx", "content-type": "application/json", "content-length": "44", '\
                 '"connection": "keep-alive", "strict-transport-security": "max-age=15768000; includeSubdomains", '\
                 '"x-xss-protection": "1; mode=block", '\
                 '"location": "https://pay.sandbox.datatrans.com/v1/start/201110082708737796", '\
                 '"correlation-id": "2eff0e4e-c9c2-439a-8cc7-8d05908b18ab"',
        response: 'OK',
        status: 201
      )
    end.not_to raise_error
  end
end
# rubocop:enable Metrics/BlockLength
