# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe Datatrans::EndpointUrlBuilder do
  describe '.build' do
    it 'returns the correct url for HealthCheck check action' do
      expect(
        described_class.build(action: :check, env: :test, service: 'HealthCheck', version: 1)
      ).to eq('https://api.sandbox.datatrans.com/upp/check')
    end

    it 'returns the correct url for Transactions init' do
      expect(
        described_class.build(action: :init, env: :live, service: 'Transactions', version: 1)
      ).to eq('https://api.datatrans.com/v1/transactions/')
    end

    it 'returns the correct url for Transactions authorize' do
      expect(
        described_class.build(action: :authorize, env: :test, service: 'Transactions', version: 1)
      ).to eq('https://api.sandbox.datatrans.com/v1/transactions/authorize')
    end

    it 'returns the correct url for Transactions authorize_with_transaction' do
      expect(
        described_class.build(
          action: :authorize_with_transaction, env: :live, id: 'ABCdef', service: 'Transactions', version: 1
        )
      ).to eq('https://api.datatrans.com/v1/transactions/ABCdef/authorize')
    end

    it 'returns the correct url for Transactions validate' do
      expect(
        described_class.build(action: :validate, env: :test, service: 'Transactions', version: 1)
      ).to eq('https://api.sandbox.datatrans.com/v1/transactions/validate')
    end

    it 'returns the correct url for Transactions settle' do
      expect(
        described_class.build(
          action: :settle, env: :live, id: 'ABCdef', service: 'Transactions', version: 1
        )
      ).to eq('https://api.datatrans.com/v1/transactions/ABCdef/settle')
    end

    it 'returns the correct url for Transactions cancel' do
      expect(
        described_class.build(
          action: :cancel, env: :test, id: 'ABCdef', service: 'Transactions', version: 1
        )
      ).to eq('https://api.sandbox.datatrans.com/v1/transactions/ABCdef/cancel')
    end

    it 'returns the correct url for Transactions credit' do
      expect(
        described_class.build(action: :credit, env: :live, service: 'Transactions', version: 1)
      ).to eq('https://api.datatrans.com/v1/transactions/credit')
    end

    it 'returns the correct url for Transactions credit_with_transaction' do
      expect(
        described_class.build(
          action: :credit_with_transaction, env: :test, id: 'ABCdef', service: 'Transactions', version: 1
        )
      ).to eq('https://api.sandbox.datatrans.com/v1/transactions/ABCdef/credit')
    end

    it 'returns the correct url for Transactions secure_fields' do
      expect(
        described_class.build(action: :secure_fields, env: :live, service: 'Transactions', version: 1)
      ).to eq('https://api.datatrans.com/v1/transactions/secureFields')
    end

    it 'returns the correct url for Transactions status' do
      expect(
        described_class.build(
          action: :status, env: :test, id: 'ABCdef', service: 'Transactions', version: 1
        )
      ).to eq('https://api.sandbox.datatrans.com/v1/transactions/ABCdef')
    end

    it 'returns the correct url for Transactions update_amount' do
      expect(
        described_class.build(
          action: :update_amount, env: :live, id: 'ABCdef', service: 'Transactions', version: 1
        )
      ).to eq('https://api.datatrans.com/v1/transactions/ABCdef')
    end

    it 'returns the correct url for Aliases delete' do
      expect(
        described_class.build(
          action: :delete, env: :test, id: 'ABCdef', service: 'Aliases', version: 1
        )
      ).to eq('https://api.sandbox.datatrans.com/v1/aliases/ABCdef')
    end

    it 'returns the correct url for Aliases convert' do
      expect(
        described_class.build(
          action: :convert, env: :live, service: 'Aliases', version: 1
        )
      ).to eq('https://api.datatrans.com/v1/aliases/')
    end

    it 'returns the correct url for Reconciliations sales' do
      expect(
        described_class.build(action: :sales, env: :test, service: 'Reconciliations', version: 1)
      ).to eq('https://api.sandbox.datatrans.com/v1/reconciliations/sales')
    end

    it 'returns the correct url for Reconciliations sales_bulk' do
      expect(
        described_class.build(
          action: :sales_bulk, env: :live, service: 'Reconciliations', version: 1
        )
      ).to eq('https://api.datatrans.com/v1/reconciliations/sales/bulk')
    end

    it 'raises error if id is required but is blank' do
      expect do
        described_class.build(
          action: %i[authorize_with_transaction cancel credit_with_transaction delete
                     status settle update_amount].sample,
          env: :live,
          service: %w[Aliases Transactions].sample,
          version: 1
        )
      end.to raise_error(ArgumentError, "Invalid id specified: ''")
    end

    it 'raises error if the service is not in the whitelist' do
      expect do
        described_class.build(action: :status, env: :live, id: 'ABCdef', service: 'Payments', version: 1)
      end.to raise_error(ArgumentError, "Invalid service specified: 'Payments'")
    end
  end
end
# rubocop:enable Metrics/BlockLength
