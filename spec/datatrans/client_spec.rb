# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Datatrans::Client do
  let(:subject) { described_class.new(env: :test, merchant_id: 'merchantId', merchant_password: 'merchantPassword') }

  it { is_expected.to respond_to(:env)               }
  it { is_expected.to respond_to(:merchant_id)       }
  it { is_expected.to respond_to(:merchant_password) }

  it { is_expected.to respond_to(:aliases)         }
  it { is_expected.to respond_to(:health_check)    }
  it { is_expected.to respond_to(:reconciliations) }
  it { is_expected.to respond_to(:transactions)    }

  it 'raises error if the env is not in the white list' do
    expect do
      described_class.new(env: :staging, merchant_id: 'merchantId', merchant_password: 'merchantPassword')
    end.to raise_error(ArgumentError, "Invalid env specified: 'staging'")
  end
end
