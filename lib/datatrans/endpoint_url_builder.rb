# frozen_string_literal: true

require 'json'

module Datatrans
  # Model wraps the Datatrans Endpoint Url Builder
  class EndpointUrlBuilder
    class << self
      def build(**args)
        new(args).build
      end
    end

    def initialize(args)
      @action = args[:action]
      @env = args[:env]
      @env_subdomain = @env == :live ? '' : '.sandbox'
      @id = args[:id]
      @service = args[:service]
      @version = args[:version]
      raise ArgumentError, 'Invalid id specified' if @id.blank? && action_requires_id?
    end

    def build
      "#{endpoint_url_base}/#{@service == 'HealthCheck' ? @action : "v#{@version}/#{@service.downcase}/#{path}"}"
    end

    private

    def action_requires_id?
      %w[Aliases Transactions].include?(@service) &&
        %i[authorize_with_transaction cancel credit_with_transaction delete
           status settle update_amount].include?(@action)
    end

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

    def path
      return path_for_secure_fields                    if secure_fields?
      return path_for_sales_bulk                       if sales_bulk?
      return @id                                       if path_with_id_only?
      return @action                                   if path_with_action_only?
      return "#{@id}/#{@action.to_s.split('_').first}" if custom_member_path?

      ''
    end

    def secure_fields?
      @service == 'Transactions' && @action == :secure_fields
    end

    def path_for_secure_fields
      @action.to_s.gsub(/_./) { |x| x[1].upcase }.to_s
    end

    def sales_bulk?
      @service == 'Reconciliations' && @action == 'sales_bulk'
    end

    def path_for_sales_bulk
      split_action = @action.to_s.split('_')
      "#{split_action.first}/#{split_action.last}"
    end

    def path_with_id_only?
      %w[Aliases Transactions].include?(@service) && %i[status update_amount delete].include?(@action)
    end

    def path_with_action_only?
      %w[Reconciliations Transactions].include?(@service) && %i[authorize validate credit sales].include?(@action)
    end

    def custom_member_path?
      @service == 'Transactions' && %i[authorize_with_transaction settle cancel].include?(@action)
    end
  end
end
