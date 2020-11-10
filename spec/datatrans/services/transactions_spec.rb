# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Datatrans::Services::Transactions do
  let(:client) do
    Datatrans::Client.new(merchant_id: 'merchantId', merchant_password: 'merchantPassword', env: :test)
  end
  let(:subject) do
    described_class.new(client)
  end

  it { is_expected.to respond_to(:init) }
  it { is_expected.to respond_to(:authorize) }
  it { is_expected.to respond_to(:authorize_with_transaction) }
  it { is_expected.to respond_to(:validate) }
  it { is_expected.to respond_to(:settle) }
  it { is_expected.to respond_to(:cancel) }
  it { is_expected.to respond_to(:credit) }
  it { is_expected.to respond_to(:credit_with_transaction) }
  it { is_expected.to respond_to(:secure_fields) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:update_amount) }
end
