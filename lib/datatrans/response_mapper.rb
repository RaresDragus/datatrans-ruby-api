# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'json'

module Datatrans
  # Model wraps the Datatrans Response Mapper
  class ResponseMapper
    ERRORS = [
      { name: :bad_request,          status: 400 }, { name: :unauthorized, status: 401 },
      { name: :permission,           status: 403 }, { name: :not_found,    status: 404 },
      { name: :unprocessable_entity, status: 422 }, { name: :server,       status: 500 },
      { name: :configuration,        status: 905 }
    ].freeze

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

    # rubocop:disable Metrics/AbcSize
    # @return [Datatrans::Result|Datatrans::Error] The result of the Response Mapper
    def build
      if [200, 201, 204].include? @response.status
        return Result.new(headers: @response.headers, response: @response.body, status: @response.status)
      end

      ERRORS.each do |error|
        if @response.status == error[:status]
          return "Datatrans::#{error[:name].to_s.classify}Error".constantize.send(:new, error_args)
        end
      end

      ApiError.new(error_args)
    end
    # rubocop:enable Metrics/AbcSize

    private

    # @return [Hash] The error attributes
    def error_args
      { request: @payload, response: @response.body, status: @response.status }
    end
  end
end
