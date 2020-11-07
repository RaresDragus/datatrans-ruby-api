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

      def initialize(client, version = DEFAULT_VERSION)
        super(client: client, methods: METHODS, service: 'Reconciliations', version: version)
      end
    end
  end
end
