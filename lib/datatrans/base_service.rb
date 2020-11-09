# frozen_string_literal: true

module Datatrans
  # Model wraps the Datatrans Service specific to an endpoint namespace
  class BaseService
    DEFAULT_VERSION = 1

    # @param [Datatrans::Client] client The library client
    # @param [Integer] version The version for the endpoint
    # @return [Integer] The new instance
    def initialize(client, version = DEFAULT_VERSION)
      @client = client
      @version = version
      define_actions
    end

    private

    # @return[Nothing] method that needs to be implemented in the descendant classes
    def methods
      raise NotImplementedError, "#{__method__} needs to be overridden in descendant class."
    end

    def define_actions
      methods.each do |method|
        define_singleton_method method[:name] do |request = {}, headers = {}|
          id = request.delete(:transactionId) || request.delete(:alias)
          @client.send_request(
            action: method[:name], id: id, headers: headers, request: request, service: self.class.name.demodulize,
            verb: method[:verb], version: @version
          )
        end
      end
    end
  end
end
