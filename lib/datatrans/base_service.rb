# frozen_string_literal: true

module Datatrans
  # Model wraps the Datatrans Service specific to an endpoint namespace
  class BaseService
    DEFAULT_VERSION = 1

    # @param [Datatrans::Client] client The client
    # @param [Integer] version The version for the endpoint
    # @return [Integer] A new instance
    def initialize(client, version = DEFAULT_VERSION)
      @client = client
      @version = version
      define_actions
    end

    private

    def define_actions
      service_methods.each do |method|
        define_singleton_method method[:name] do |request = {}, headers = {}|
          id = request.delete(:id)
          @client.send_request(
            action: method[:name], id: id, headers: headers, request: request, service: self.class.name.demodulize,
            verb: method[:verb], version: @version
          )
        end
      end
    end

    # @return[Nothing] Method that needs to be implemented in the descendant classes
    def service_methods
      raise NotImplementedError, "#{__method__} needs to be overridden in descendant class."
    end
  end
end
