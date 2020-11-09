# frozen_string_literal: true

require 'json'

module Datatrans
  # Model wraps the Datatrans Endpoint Url Builder
  class EndpointUrlBuilder
    class << self
      # @param [Hash] args
      # @return [String] The result of the Endpoint Url Builder
      def build(**args)
        new(args).build
      end
    end

    # @param [Hash] args
    # @return [Datatrans::EndpointUrlBuilder] The new instance
    def initialize(args)
      @action = args[:action]
      @env = args[:env]
      @env_subdomain = @env == :live ? '' : '.sandbox'
      @id = args[:id]
      @service = args[:service]
      @version = args[:version]
      raise ArgumentError, 'Invalid id specified' if @id.blank? && action_requires_id?

      define_helpers
    end

    # @return [String] The result of the Endpoint Url Builder
    def build
      "#{endpoint_url_base}/#{@service == 'HealthCheck' ? @action : "v#{@version}/#{@service.downcase}/#{path}"}"
    end

    private

    # @return [Boolean] Boolean method that checks if id is required in the path
    def action_requires_id?
      %w[Aliases Transactions].include?(@service) &&
        %i[authorize_with_transaction cancel credit_with_transaction delete
           status settle update_amount].include?(@action)
    end

    # path_with_special_camelcase?
    # @return [Boolean] Boolean method that checks if the path requires a special camelcase
    # path_with_special_camelcase
    # @return [String] The path with special camelcase (eg. secure_fields => secureFields)
    # path_with_splitting?
    # @return [Boolean] Boolean method that checks if the path requires splitting
    # path_with_splitting
    # @return [String] The path with splitting (eg. sales_bulk => sales/bulk)
    # path_with_custom_member?
    # @return [Boolean] Boolean method that checks if the path requires custom member
    # path_with_custom_member
    # @return [String] The path with custom member (eg. credit_with_transaction => {transactionId}/credit)
    # path_with_member_only?
    # @return [Boolean] Boolean method that checks if the path requires member only
    # path_with_member_only
    # @return [String] The path with member only (eg. status => {transactionId})
    # path_with_collection_only?
    # @return [Boolean] Boolean method that checks if the path requires collection only
    # path_with_collection_only
    # @return [String] The path with collection only (eg. authorize => authorize)
    def define_helpers
      methods.each do |method|
        define_singleton_method ":path_with_#{method[:name]}?" do
          method[:condition]
        end

        define_singleton_method ":path_with_#{method[:name]}" do
          method[:value]
        end
      end
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    # @return [Array<Hash>] Array of name, condition, and value used for building the paths
    def methods
      [
        {
          name: :special_camelcase,
          condition: @service == 'Transactions' && @action == :secure_fields,
          value: @action.to_s.gsub(/_./) { |x| x[1].upcase }.to_s
        },
        {
          name: :splitting,
          condition: @service == 'Reconciliations' && @action == :sales_bulk,
          value: "#{@action.to_s.split('_').first}/#{@action.to_s.split('_').last}"
        },
        {
          name: :custom_member,
          condition: @service == 'Transactions' &&
            %i[authorize_with_transaction cancel credit_with_transaction settle].include?(@action),
          value: "#{@id}/#{@action.to_s.split('_').first}"
        },
        {
          name: :member_only,
          condition: %w[Aliases Transactions].include?(@service) && %i[delete status update_amount].include?(@action),
          value: @id
        },
        {
          name: :collection_only,
          condition: %w[Reconciliations Transactions].include?(@service) &&
            %i[authorize credit sales validate].include?(@action),
          value: @action
        }
      ]
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # @return [String] The base endpoint Url
    def endpoint_url_base
      case @service
      when 'HealthCheck'
        "https://api#{@env_subdomain}.datatrans.com/upp"
      when 'Aliases', 'Reconciliations', 'Transactions'
        "https://api#{@env_subdomain}.datatrans.com"
      else
        raise ArgumentError, 'Invalid service specified'
      end
    end

    # @return [String] The endpoint path
    def path
      methods.map { |method| method[:name] }.each do |method_name|
        return send(":path_with_#{method_name}") if send(":path_with_#{method_name}?")
      end

      ''
    end
  end
end
