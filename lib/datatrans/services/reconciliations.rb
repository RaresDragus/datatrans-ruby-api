# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Reconciliations Service
    class Reconciliations < BaseService
      DEFAULT_VERSION = 1
      METHODS = [
        { name: :sales,      verb: :post },
        { name: :sales_bulk, verb: :post }
      ].freeze

      # @param [Datatrans::Client] client The library client
      # @param [Integer] version The version for the endpoint
      # @return [Integer] The new instance
      def initialize(client, version = DEFAULT_VERSION)
        super(client: client, methods: METHODS, service: 'Reconciliations', version: version)
      end
    end
  end
end
