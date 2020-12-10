# frozen_string_literal: true

module Datatrans
  # Model wraps the Datatrans Service specific to an endpoint namespace
  class BaseService
    DEFAULT_VERSION = 1

    # @param client [Datatrans::Client] The client
    # @param version [Integer] The version for the endpoint
    # @return [Integer] A new instance
    def initialize(client, version = DEFAULT_VERSION)
      @client = client
      @version = version
      define_actions
    end

    private

    # @!method convert
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Aliases convert request
    # @!method delete
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Aliases delete request
    # @!method check
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the HealthCheck check request
    # @!method sales
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Reconciliations sales request
    # @!method sales_bulk
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Reconciliations sales_bulk request
    # @!method authorize
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Transactions authorize request
    # @!method authorize_with_transaction
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Transactions authorize_with_transaction
    # @!method cancel
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Transactions cancel request
    # @!method credit
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Transactions credit request
    # @!method credit_with_transaction
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Transactions credit_with_transaction
    # @!method init
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Transactions init request
    # @!method secure_fields
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Transactions secure_fields request
    # @!method settle
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Transactions settle request
    # @!method status
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Transactions status request
    # @!method update_amount
    #   @return [Datatrans::Result|Datatrans::DatatransError] The result of the Transactions update_amount request
    # Defines the subclasses request methods
    def define_actions
      service_methods.each do |method|
        define_singleton_method method[:name] do |request = {}, headers = {}|
          id = request.delete(:id)
          @client.send_request(
            action: method[:name], id: id, headers: headers, request: request, service: self.class.name.demodulize,
            verb: method[:verb], version: @version
          )
        end
      end
    end

    # @return[Nothing] Method that needs to be implemented in the descendant classes
    def service_methods
      raise NotImplementedError, "#{__method__} needs to be overridden in descendant class."
    end
  end
end
