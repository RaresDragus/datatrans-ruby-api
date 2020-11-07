# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'faraday'
require 'json'

module Datatrans
  # Model wraps the Datatrans Result
  class Client
    def initialize(user: nil, password: nil, env: :live)
      @user = user
      @password = password
      unless %i[live test].include? env
        raise ArgumentError, "Invalid value for Client.env: '#{env}'' - must be one of [:live, :test]"
      end

      @env = env
    end

    def send_request(**args)
      result = call_api(
        endpoint_url(
          service: args.dig(:service), action: args.dig(:action), version: args.dig(:version),
          id: args.dig(:id)
        ),
        args
      )
      map_result(*result)
    end

    private

    def call_api(url, args)
      request = args.dig(:request)
      request_data = ((JSON.parse(request) if request.is_a?(String)) || request).to_json
      begin
        response = connection(url, args.dig(:headers)).send(args.dig(:verb)) { |req| req.body = request_data }
      rescue Faraday::ConnectionFailed => e
        raise e, "Connection to #{url} failed"
      end

      [response, request_data]
    end

    def endpoint_url(service:, action:, version:, id: nil)
      if service == 'HealthCheck'
        "#{endpoint_url_base(service)}/#{action}"
      elsif service == 'Transactions' && %i[secure_fields].include?(action)
        "#{endpoint_url_base(service)}/v#{version}/#{service.downcase}/#{action.to_s.gsub(/_./) { |x| x[1].upcase }}"
      elsif %w[Aliases Transactions].include?(service) && %i[status update_amount delete].include?(action)
        "#{endpoint_url_base(service)}/v#{version}/#{service.downcase}/#{id}"
      elsif service == 'Transactions' && %i[authorize_with_transaction settle cancel].include?(action)
        "#{endpoint_url_base(service)}/v#{version}/#{service.downcase}/#{id}/#{action.to_s.split('_').first}"
      elsif %w[Reconciliations Transactions].include?(service) && %i[authorize validate credit sales].include?(action)
        "#{endpoint_url_base(service)}/v#{version}/#{service.downcase}/#{action}"
      elsif service == 'Reconciliations' && action == 'sales_bulk'
        split_action = action.to_s.split('_')
        "#{endpoint_url_base(service)}/v#{version}/#{service.downcase}/#{split_action.first}/#{split_action.last}"
      else
        "#{endpoint_url_base(service)}/v#{version}/#{service.downcase}"
      end
    end

    def endpoint_url_base(service)
      env_url = @env == :live ? '' : '.sandbox'
      case service
      when 'HealthCheck'
        url = "https://api#{env_url}.datatrans.com/upp"
      when 'Aliases' || 'Reconciliations' || 'Transactions'
        url = "https://api#{env_url}.datatrans.com"
      else
        raise ArgumentError, 'Invalid service specified'
      end

      url
    end

    def connection(url, headers)
      Faraday.new(url: url) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.headers['Content-Type'] = 'application/json'
        faraday.headers['User-Agent'] = Datatrans::NAME + '/' + Datatrans::VERSION
        faraday.basic_auth(@user, @password)
        headers.map { |key, value| faraday.headers[key] = value }
      end
    end

    def map_result(response, request_data)
      case response.status
      when 401
        raise StandardError, "Invalid API authentication: #{request_data}"
      when 403
        raise StandardError, "Missing user permissions: #{request_data}"
      else
        Result.new(response.body, response.headers, response.status)
      end
    end

    %i[aliases health_check reconciliations transactions].each do |method|
      define_method method do
        instance_variable_set(
          "@#{method}", "Datatrans::Services::#{method.to_s.camelcase}".constantize.send(:new, self)
        )
      end
    end
  end
end
