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
    ERRORS = [
      { name: :bad_request,  status: 400 }, { name: :unprocessable_entity, status: 422 },
      { name: :unauthorized, status: 401 }, { name: :server,               status: 500 },
      { name: :permission,   status: 403 }, { name: :configuration,        status: 905 },
      { name: :not_found,    status: 404 }
    ].freeze

    attr_reader :code, :message, :request, :status

    # @param request [Hash] The payload used for the request
    # @param response [String] The body received from Datatrans response
    # @param status [Integer] The status code of the response
    def initialize(request:, response:, status:)
      parsed_response = ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(response))
      @code = parsed_response.dig(:error, :code)
      @message = parsed_response.dig(:error, :message)
      @request = request
      @status = status
    end

    # @abstract class BadRequestError < DatatransError
    # @abstract class UnauthorizedError < DatatransError
    # @abstract class PermissionError < DatatransError
    # @abstract class NotFoundError < DatatransError
    # @abstract class UnprocessableEntityError < DatatransError
    # @abstract class ServerError < DatatransError
    # @abstract class ConfigurationError < DatatransError
    # dynamically defines the error subclasses
    ERRORS.map { |error| error[:name] }.each do |name|
      Datatrans.const_set "#{name.to_s.classify}Error", Class.new(self)
    end
  end

  # Model wraps the generic api errors
  class ApiError < DatatransError; end
end
