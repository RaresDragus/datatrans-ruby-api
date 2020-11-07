# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Health Check Service
    class HealthCheck < BaseService
      DEFAULT_VERSION = 1

      def initialize(client, version = DEFAULT_VERSION)
        super(client: client, methods: [{ name: :check, verb: :get }], service: 'HealthCheck', version: version)
      end
    end
  end
end
