# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Aliases Service
    class Aliases < BaseService
      private

      # @return [Array<Hash>] An array of actions and verbs used for requests
      def service_methods
        [{ name: :convert, verb: :post }, { name: :delete, verb: :delete }]
      end
    end
  end
end
