# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Health Check Service
    class HealthCheck < BaseService
      DEFAULT_VERSION = 1

      def initialize(client, version = DEFAULT_VERSION)
        super(client, version, 'HealthCheck', [{ name: :check, verb: :get }])
      end
    end
  end
end
