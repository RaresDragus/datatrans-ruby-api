# frozen_string_literal: true

require 'json'

module Datatrans
  # Model wraps the Datatrans Endpoint Url Builder
  class EndpointUrlBuilder
    class << self
      # @return [Hash] args
      # @return [String] The result of the Endpoint Url Builder
      def build(**args)
        new(args).build
      end
    end

    # @return [Hash] args
    # @return [Datatrans::EndpointUrlBuilder] The new instance
    def initialize(args)
      @action = args[:action]
      @env = args[:env]
      @env_subdomain = @env == :live ? '' : '.sandbox'
      @id = args[:id]
      @service = args[:service]
      @version = args[:version]
      raise ArgumentError, 'Invalid id specified' if @id.blank? && action_requires_id?
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
      return path_with_special_camelcase if path_with_special_camelcase?
      return path_with_splitting         if path_with_splitting?
      return @id                         if path_with_id_only?
      return @action                     if path_with_action_only?
      return custom_path                 if custom_member_path?

      ''
    end

    # @return [Boolean] Boolean method that checks if the path requires special camelcase
    def path_with_special_camelcase?
      @service == 'Transactions' && @action == :secure_fields
    end

    # @return [String] The path with special camelcase
    def path_with_special_camelcase
      @action.to_s.gsub(/_./) { |x| x[1].upcase }.to_s
    end

    # @return [Boolean] Boolean method that checks if the path requires splitting
    def path_with_splitting?
      @service == 'Reconciliations' && @action == :sales_bulk
    end

    # @return [String] The path with splitting
    def path_with_splitting
      split_action = @action.to_s.split('_')
      "#{split_action.first}/#{split_action.last}"
    end

    # @return [Boolean] Boolean method that checks if the path requires id only
    def path_with_id_only?
      %w[Aliases Transactions].include?(@service) && %i[delete status update_amount].include?(@action)
    end

    # @return [Boolean] Boolean method that checks if the path requires action only
    def path_with_action_only?
      %w[Reconciliations Transactions].include?(@service) && %i[authorize credit sales validate].include?(@action)
    end

    # @return [Boolean] Boolean method that checks if the path requires custom member
    def custom_member_path?
      @service == 'Transactions' &&
        %i[authorize_with_transaction cancel credit_with_transaction settle].include?(@action)
    end

    # @return [String] The path with custom member
    def custom_path
      "#{@id}/#{@action.to_s.split('_').first}"
    end
  end
end
