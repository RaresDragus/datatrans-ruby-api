# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Datatrans::Services::Aliases do
  let(:client)  { Datatrans::Client.new(env: :test, merchant_id: 'merchantId', merchant_password: 'merchantPassword') }
  let(:subject) { described_class.new(client) }

  it { is_expected.to respond_to(:convert) }
  it { is_expected.to respond_to(:delete)  }
end
