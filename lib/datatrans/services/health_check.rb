# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Health Check Service
    class HealthCheck < BaseService
      private

      # @return [Array<Hash>] An array of actions and verbs used for requests
      def service_methods
        [{ name: :check, verb: :get }]
      end
    end
  end
end
