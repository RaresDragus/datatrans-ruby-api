# frozen_string_literal: true

require 'json'

module Datatrans
  # Model wraps the Datatrans Endpoint Url Builder
  class EndpointUrlBuilder
    class << self
      # @param [Hash] args The attributes to create the url
      # @option args [Symbol] :action The action used for the Url
      # @option args [Symbol] :env The environment used for the Url
      # @option args [String] :service The service used for the Url
      # @option args [Integer] :version The version used for the Url
      # @return [String] The result of the Endpoint Url Builder
      def build(**args)
        new(args).build
      end
    end

    # @param [Hash] args The attributes to create the url
    # @option args [Symbol] :action The action used for the Url
    # @option args [Symbol] :env The environment used for the Url
    # @option args [String] :service The service used for the Url
    # @option args [Integer] :version The version used for the Url
    # @return [Datatrans::EndpointUrlBuilder] A new instance
    def initialize(args)
      @action = args[:action]
      @env_subdomain = args[:env] == :live ? '' : '.sandbox'
      @id = args[:id]
      @service = args[:service]
      @version = args[:version]
      raise ArgumentError, "Invalid id specified: '#{@id}'" if @id.blank? && action_requires_id?

      define_helpers
    end

    # @return [String] The result of the Endpoint Url Builder
    def build
      "#{base_uri}#{path.nil? ? '' : "/#{path}"}"
    end

    private

    # @return [Boolean] Boolean method that checks if id is required in the path
    def action_requires_id?
      %w[Aliases Transactions].include?(@service) &&
        %i[authorize_with_transaction cancel credit_with_transaction delete status settle
           update_amount].include?(@action)
    end

    # @return [String] The base URI
    def base_uri
      "#{domain}/#{resource_name}"
    end

    # @return [String] The domain
    def domain
      "https://api#{@env_subdomain}.datatrans.com"
    end

    # @return [String] The resource name
    def resource_name
      case @service
      when 'HealthCheck'
        'upp'
      when 'Aliases', 'Reconciliations', 'Transactions'
        "v#{@version}/#{@service.downcase}"
      else
        raise ArgumentError, "Invalid service specified: '#{@service}'"
      end
    end

    # @!method path_with_special_camelcase?
    #   @return [Boolean] Boolean method that checks if the path requires a special camelcase
    # @!method path_with_special_camelcase
    #  @return [String] The path with special camelcase (eg. secure_fields => secureFields)
    # @!method path_with_splitting?
    #   @return [Boolean] Boolean method that checks if the path requires splitting
    # @!method path_with_splitting
    #   @return [String] The path with splitting (eg. sales_bulk => sales/bulk)
    # @!method path_with_custom_member?
    #   @return [Boolean] Boolean method that checks if the path requires custom member
    # @!method path_with_custom_member
    #   @return [String] The path with custom member (eg. credit_with_transaction => :transactionId/credit)
    # @!method path_with_member_only?
    #   @return [Boolean] Boolean method that checks if the path requires member only
    # @!method path_with_member_only
    #   @return [String] The path with member only (eg. status => :transactionId)
    # @!method path_with_collection_only?
    #   @return [Boolean] Boolean method that checks if the path requires collection only
    # @!method path_with_collection_only
    #   @return [String] The path with collection only (eg. authorize => authorize)
    # Defines the `path_with_*` methods
    def define_helpers
      helper_methods.each do |method|
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

    # @return [Array<Hash>] An array of name, condition, and value used for building the paths
    def helper_methods
      [
        {
          name: :collection_only,
          condition: %w[HealthCheck Reconciliations Transactions].include?(@service) &&
            %i[authorize check credit sales validate].include?(@action),
          value: @action
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
          name: :special_camelcase,
          condition: @service == 'Transactions' && @action == :secure_fields,
          value: @action.to_s.gsub(/_./) { |x| x[1].upcase }.to_s
        },
        {
          name: :splitting,
          condition: @service == 'Reconciliations' && @action == :sales_bulk,
          value: "#{@action.to_s.split('_').first}/#{@action.to_s.split('_').last}"
        }
      ]
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # @return [String|NilClass] The endpoint's path
    def path
      helper_methods.map { |method| method[:name] }.each do |method_name|
        return send(":path_with_#{method_name}") if send(":path_with_#{method_name}?")
      end

      nil
    end
  end
end
