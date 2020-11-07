# frozen_string_literal: true

require 'json'

module Datatrans
  # Model wraps the Datatrans Response Mapper
  class ResponseMapper
    class << self
      def build(response, params)
        new(response, params).build
      end
    end

    def initialize(response, params)
      @response = response
      @params = params
    end

    def build
      case @response.status
      when 401
        raise StandardError, "Invalid API authentication: #{@params}"
      when 403
        raise StandardError, "Missing user permissions: #{@params}"
      else
        Result.new(header: response.headers, response: response.body, status: response.status)
      end
    end
  end
end
