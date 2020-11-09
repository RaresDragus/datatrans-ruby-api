# frozen_string_literal: true

module Datatrans
  # Model wraps the Datatrans Service specific to an endpoint namespace
  #
  # @!attribute [rw] service
  #   @return [String] The name of the service
  # @!attribute [rw] version
  #   @return [Integer] The version for the endpoint
  class BaseService
    attr_accessor :service, :version

    # @param [Datatrans::Client] client The library client
    # @param [Array<Hash>] methods Array of actions and verbs used for requests
    # @param [String] service The name of the service
    # @param [Integer] version The version for the endpoint
    # @return [Integer] The new instance
    def initialize(client:, methods:, service:, version:)
      @client = client
      @service = service
      @version = version
      define_actions(methods)
    end

    private

    # @param [Array<Hash>] methods Array of actions and verbs used for requests
    def define_actions(methods)
      methods.each do |method|
        define_singleton_method method[:name] do |request = {}, headers = {}|
          id = request.delete(:transactionId) || request.delete(:alias)
          @client.send_request(
            action: method[:name], id: id, headers: headers, request: request, service: @service,
            verb: method[:verb], version: @version
          )
        end
      end
    end
  end
end
