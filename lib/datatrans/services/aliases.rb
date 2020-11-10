# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Aliases Service
    class Aliases < BaseService
      private

      # @return [Array<Hash>] methods Array of actions and verbs used for requests
      def service_methods
        [{ name: :delete, verb: :delete }, { name: :convert, verb: :post }]
      end
    end
  end
end
