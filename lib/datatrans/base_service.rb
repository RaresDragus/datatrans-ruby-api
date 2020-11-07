# frozen_string_literal: true

module Datatrans
  # Model wraps the Datatrans Service specific to an endpoint namespace
  class BaseService
    attr_accessor :service, :version

    def initialize(client, version, service, methods)
      @client = client
      @version = version
      @service = service
      define_actions(methods)
    end

    private

    def define_actions(methods)
      methods.each do |method|
        define_singleton_method method.dig(:name) do |request = {}, headers = {}|
          id = request.delete(:transactionId) || request.delete(:alias)
          @client.send_request(
            verb: method.dig(:verb), service: @service, request: request, headers: headers, version: @version,
            action: method.dig(:name), id: id
          )
        end
      end
    end
  end
end
