# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Datatrans::Services::Reconciliations do
  let(:client) do
    Datatrans::Client.new(merchant_id: 'merchantId', merchant_password: 'merchantPassword', env: :test)
  end
  let(:subject) do
    described_class.new(client)
  end

  it { is_expected.to respond_to(:sales) }
  it { is_expected.to respond_to(:sales_bulk) }
end
