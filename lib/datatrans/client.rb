# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'faraday'
require 'json'

module Datatrans
  # Model wraps the Datatrans Client
  class Client
    attr_accessor :merchant_id, :merchant_password, :env

    # @param [String] merchant_id The merchant id
    # @param [String] merchant_password The merchant password
    # @param [Symbol] env The environment (live or test)
    # @return [Datatrans::Client] The new instance
    def initialize(merchant_id: nil, merchant_password: nil, env: :live)
      @merchant_id = merchant_id
      @merchant_password = merchant_password
      raise ArgumentError, "Invalid env specified: '#{env}'" unless %i[live test].include? env

      @env = env
    end

    # @param [Hash] args The attributes for the new request
    # @return [Datatrans::Result|Datatrans::Error] The result of the request
    def send_request(**args)
      ResponseMapper.build(
        *call_api(
          EndpointUrlBuilder.build(
            action: args[:action], env: @env, id: args[:id], service: args[:service], version: args[:version]
          ),
          args
        )
      )
    end

    # aliases
    # @return [Datatrans::Services::Aliases] New instance for aliases
    # health_check
    # @return [Datatrans::Services::HealthCheck] New instance for health check
    # reconciliations
    # @return [Datatrans::Services::Reconciliations] New instance for reconciliations
    # transactions
    # @return [Datatrans::Services::Transactions] New instance for transactions
    %i[aliases health_check reconciliations transactions].each do |method|
      define_method method do
        instance_variable_set(
          "@#{method}", "Datatrans::Services::#{method.to_s.camelcase}".constantize.send(:new, self)
        )
      end
    end

    private

    # @param [String] url The url for the new request
    # @param [Hash] args The attributes for the new request
    # @return [Array<Faraday::Response, Hash>] The Faraday response and the payload which was sent
    def call_api(url, args)
      request = args[:request]
      request_data = ((JSON.parse(request) if request.is_a?(String)) || request).to_json
      begin
        response = connection(url, args[:headers]).send(args[:verb]) { |req| req.body = request_data }
      rescue Faraday::ConnectionFailed => e
        raise e, "Connection to #{url} failed"
      end

      [response, request_data]
    end

    # @param [String] url The url for the new connection
    # @param [Hash] headers The headers for the new connection
    # @return [Faraday] The new Faraday instance
    def connection(url, headers)
      Faraday.new(url: url) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.headers['Content-Type'] = 'application/json'
        faraday.headers['User-Agent'] = "#{Datatrans::NAME}/#{Datatrans::VERSION}"
        faraday.basic_auth(@merchant_id, @merchant_password)
        headers.map { |key, value| faraday.headers[key] = value }
      end
    end
  end
end
