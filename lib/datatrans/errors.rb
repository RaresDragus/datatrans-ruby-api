# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'

module Datatrans
  # Model wraps the Datatrans errors
  #
  # @!attribute [r] code
  #   @return [Integer] The code of the error
  # @!attribute [r] message
  #   @return [Integer] The message of the error
  # @!attribute [r] request
  #   @return [Hash] The payload used for the request
  # @!attribute [r] status
  #   @return [Integer] The status code of the response
  class DatatransError
    attr_reader :code, :message, :request, :status

    # @param [Hash] request The payload used for the request
    # @param [String] response The body received from Datatrans response
    # @param [Integer] status The status code of the response
    def initialize(request:, response:, status:)
      parsed_response = ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(response))
      @code = parsed_response.dig(:error, :code)
      @message = parsed_response.dig(:error, :message)
      @request = request
      @status = status
    end
  end

  # Model wraps the bad request errors
  class BadRequestError < DatatransError; end

  # Model wraps the authentication errors
  class UnauthorizedError < DatatransError; end

  # Model wraps the permission errors
  class PermissionError < DatatransError; end

  # Model wraps the not found errors
  class NotFoundError < DatatransError; end

  # Model wraps the format errors
  class UnprocessableEntityError < DatatransError; end

  # Model wraps the server errors
  class ServerError < DatatransError; end

  # Model wraps the configuration errors
  class ConfigurationError < DatatransError; end

  # Model wraps the generic api errors
  class ApiError < DatatransError; end
end
