# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'faraday'
require 'json'

module Datatrans
  # Model wraps the Datatrans Client
  #
  # @!attribute [rw] env
  #   @return [Symbol] The environment (live or test)
  # @!attribute [rw] merchant_id
  #   @return [String] The merchant id
  # @!attribute [rw] merchant_password
  #   @return [String] The merchant password
  class Client
    attr_accessor :env, :merchant_id, :merchant_password

    # @param env [Symbol] The environment (live or test)
    # @param merchant_id [String] The merchant id
    # @param merchant_password [String] The merchant password
    # @return [Datatrans::Client] A new instance
    def initialize(env: :live, merchant_id: nil, merchant_password: nil)
      raise ArgumentError, "Invalid env specified: '#{env}'" unless %i[live test].include?(env)

      @env = env
      @merchant_id = merchant_id
      @merchant_password = merchant_password
    end

    # @param args [Hash] The attributes for the new request
    # @return [Datatrans::Result|Datatrans::DatatransError] The result of the request
    def send_request(**args)
      ResponseMapper.build(
        *call(
          args,
          EndpointUrlBuilder.build(
            action: args[:action], env: @env, id: args[:id], service: args[:service], version: args[:version]
          )
        )
      )
    end

    # @!method aliases
    #   @return [Datatrans::Services::Aliases] A new Aliases Service instance
    # @!method health_check
    #   @return [Datatrans::Services::HealthCheck] A new Health Check Service instance
    # @!method reconciliations
    #   @return [Datatrans::Services::Reconciliations] A new Reconciliations Service instance
    # @!method transactions
    #   @return [Datatrans::Services::Transactions] A new Transactions Service instance
    %i[aliases health_check reconciliations transactions].each do |method|
      define_method method do
        instance_variable_set(
          "@#{method}", "Datatrans::Services::#{method.to_s.camelcase}".constantize.send(:new, self)
        )
      end
    end

    private

    # @param args [Hash] The attributes for the new request
    # @param url [String]The url for the new request
    # @return [Array<Hash, Faraday::Response>] The payload which was sent and the response
    def call(args, url)
      request = args[:request]
      request_data = ((JSON.parse(request) if request.is_a?(String)) || request).to_json
      begin
        response = connection(args[:headers], url).send(args[:verb]) { |req| req.body = request_data }
      rescue Faraday::ConnectionFailed => e
        raise e, "Connection to #{url} failed"
      end

      [request_data, response]
    end

    # @param headers [Hash] The headers for the new connection
    # @param url [String] The url for the new connection
    # @return [Faraday] A new Faraday instance
    def connection(headers, url)
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
