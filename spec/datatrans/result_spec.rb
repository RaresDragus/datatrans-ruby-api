# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Datatrans::Result do
  let(:subject) do
    described_class.new(
      headers: '"server": "nginx", "content-type": "application/json", "content-length": "44"',
      response: { transactionId: '201110082708737796' }.to_json,
      status: 201
    )
  end

  it { is_expected.to respond_to(:headers)  }
  it { is_expected.to respond_to(:response) }
  it { is_expected.to respond_to(:status)   }

  it 'does not raise error if the response is only a string (eg: "OK")' do
    expect do
      described_class.new(
        headers: '"server": "nginx", "content-type": "application/json", "content-length": "44"',
        response: 'OK',
        status: 201
      )
    end.not_to raise_error
  end
end
