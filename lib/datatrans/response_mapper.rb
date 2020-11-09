# frozen_string_literal: true

require 'json'

module Datatrans
  # Model wraps the Datatrans Response Mapper
  class ResponseMapper
    class << self
      # @param [Faraday::Response] response
      # @param [Hash] payload The payload that was sent
      # @return [Datatrans::Result|Datatrans::Error] The result of the Response Mapper
      def build(response, payload)
        new(response, payload).build
      end
    end

    # @param [Faraday::Response] response
    # @param [Hash] payload The payload that was sent
    # @return [Datatrans::ResponseMapper] The new instance
    def initialize(response, payload)
      @response = response
      @payload = payload
    end

    # @return [Datatrans::Result|Datatrans::Error] The result of the Response Mapper
    def build
      case @response.status
      when 401
        raise StandardError, "Invalid API authentication: #{@payload}"
      when 403
        raise StandardError, "Missing user permissions: #{@payload}"
      else
        Result.new(headers: @response.headers, response: @response.body, status: @response.status)
      end
    end
  end
end
