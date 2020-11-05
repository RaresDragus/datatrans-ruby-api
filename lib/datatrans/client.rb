# frozen_string_literal: true

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

    def endpoint_url_base(service)
      env_url = @env == :live ? '' : '.sandbox'
      case service
      when 'HealthCheck'
        url = "https://api#{env_url}.datatrans.com/upp"
      else
        raise ArgumentError, 'Invalid service specified'
      end

      url
    end

    def endpoint_url(service, action, version)
      if service == 'HealthCheck'
        "#{endpoint_url_base(service)}/#{action}"
      else
        "#{endpoint_url_base(service)}/v#{version}/#{action}"
      end
    end

    def send_request(**args)
      result = call_api(endpoint_url(args.dig(:service), args.dig(:action), args.dig(:version)), args)
      map_result(*result)
    end

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

    def health_check
      @health_check ||= Datatrans::Services::HealthCheck.new(self)
    end
  end
end
