# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'json'

module Datatrans
  # Model wraps the Datatrans Result
  #
  # @!attribute [r] headers
  #   @return [Hash] The headers received from Datatrans response
  # @!attribute [r] response
  #   @return [String|Hash] The body received from Datatrans response
  # @!attribute [r] status
  #   @return [Integer] The status code received from Datatrans response
  class Result
    attr_reader :headers, :response, :status

    # @param [String] headers The headers received from Faraday::Response
    # @param [String|NilClass] response The body received from Faraday::Response
    # @param [Integer|NilClass] status The status code received from Faraday::Response
    # @return [Datatrans::Result] New instance
    def initialize(headers:, response:, status:)
      @headers = ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(headers.to_json))
      @response = ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(response))
      @status = status
    rescue JSON::ParserError
      @headers = headers
      @response = response
      @status = status
    end
  end
end
