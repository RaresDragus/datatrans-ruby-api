# frozen_string_literal: true

require 'json'

module Datatrans
  # Model wraps the Datatrans Result
  class Result
    attr_reader :response, :header, :status

    def initialize(response, header, status)
      @response = JSON.parse([response].to_json).first
      @header = JSON.parse(header.to_json)
      @status = status
    end
  end
end
