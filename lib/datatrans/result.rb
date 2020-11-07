# frozen_string_literal: true

require 'json'

module Datatrans
  # Model wraps the Datatrans Result
  class Result
    attr_reader :header, :response, :status

    def initialize(header:, response:, status:)
      @header = JSON.parse(header.to_json)
      @response = JSON.parse([response].to_json).first
      @status = status
    end
  end
end
