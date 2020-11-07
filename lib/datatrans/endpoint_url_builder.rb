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
      @action = args.dig(:action)
      @env = args.dig(:env)
      @env_subdomain = @env == :live ? '' : '.sandbox'
      @id = args.dig(:id)
      @service = args.dig(:service)
      @version = args.dig(:version)
    end

    def build
      "#{endpoint_url_base}/#{@service == 'HealthCheck' ? @action : "v#{@version}/#{@service.downcase}/#{path}"}"
    end

    private

    def endpoint_url_base
      @endpoint_url_base ||= case @service
                             when 'HealthCheck'
                               "https://api#{@env_subdomain}.datatrans.com/upp"
                             when 'Aliases', 'Reconciliations', 'Transactions'
                               "https://api#{@env_subdomain}.datatrans.com"
                             else
                               raise ArgumentError, 'Invalid service specified'
                             end
    end

    def path
      return path_for_secure_fields if secure_fields?
      return path_for_sales_bulk if sales_bulk?
      return @id if path_needs_id?

      custom_path
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

    def path_needs_id?
      %w[Aliases Transactions].include?(@service) && %i[status update_amount delete].include?(@action)
    end

    def custom_path
      if @service == 'Transactions' && %i[authorize_with_transaction settle cancel].include?(@action)
        "#{@id}/#{@action.to_s.split('_').first}"
      elsif %w[Reconciliations Transactions].include?(@service) && %i[authorize validate credit sales].include?(@action)
        @action
      else
        ''
      end
    end
  end
end
