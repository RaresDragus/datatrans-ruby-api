# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Datatrans::Services::Reconciliations do
  let(:client)  { Datatrans::Client.new(env: :test, merchant_id: 'merchantId', merchant_password: 'merchantPassword') }
  let(:subject) { described_class.new(client) }

  it { is_expected.to respond_to(:sales)      }
  it { is_expected.to respond_to(:sales_bulk) }
end
