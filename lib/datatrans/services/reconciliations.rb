# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Reconciliations Service
    class Reconciliations < BaseService
      private

      # @return [Array<Hash>] methods Array of actions and verbs used for requests
      def methods
        [{ name: :sales, verb: :post }, { name: :sales_bulk, verb: :post }]
      end
    end
  end
end
