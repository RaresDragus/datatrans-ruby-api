# frozen_string_literal: true

module Datatrans
  # Model wraps the Datatrans Service specific to an endpoint namespace
  class BaseService
    attr_accessor :service, :version

    class << self
      def to_camel_case(method_name)
        method_name.to_s.gsub(/_./) { |x| x[1].upcase }
      end
    end

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
          @client.send_request(
            verb: method.dig(:verb), service: @service, request: request, headers: headers, version: @version,
            action: self.class.to_camel_case(method.dig(:name))
          )
        end
      end
    end
  end
end
