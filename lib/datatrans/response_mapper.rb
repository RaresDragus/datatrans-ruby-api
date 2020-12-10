# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'json'

module Datatrans
  # Model wraps the Datatrans Response Mapper
  class ResponseMapper
    class << self
      # @param payload [Hash] The payload that was sent
      # @param response[Faraday::Response] The Datatrans response
      # @return [Datatrans::Result|Datatrans::DatatransError] The result of the Response Mapper
      def build(payload, response)
        new(payload, response).build
      end
    end

    # @param payload [Hash] The payload that was sent
    # @param response [Faraday::Response]
    # @return [Datatrans::ResponseMapper] A new instance
    def initialize(payload, response)
      @payload = payload
      @response = response
    end

    # rubocop:disable Metrics/AbcSize
    # @return [Datatrans::Result|Datatrans::DatatransError] The result of the Response Mapper
    def build
      if [200, 201, 204].include? @response.status
        return Result.new(headers: @response.headers, response: @response.body, status: @response.status)
      end

      DatatransError::ERRORS.each do |error|
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
