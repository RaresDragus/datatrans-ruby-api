# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Reconciliations Service
    class Reconciliations < BaseService
      private

      # @return [Array<Hash>] An array of actions and verbs used for requests
      def service_methods
        [{ name: :sales, verb: :post }, { name: :sales_bulk, verb: :post }]
      end
    end
  end
end
