# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Health Check Service
    class HealthCheck < BaseService
      DEFAULT_VERSION = 1

      # @param [Datatrans::Client] client The library client
      # @param [Integer] version The version for the endpoint
      # @return [Integer] The new instance
      def initialize(client, version = DEFAULT_VERSION)
        super(client: client, methods: [{ name: :check, verb: :get }], service: 'HealthCheck', version: version)
      end
    end
  end
end
