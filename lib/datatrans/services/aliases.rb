# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Aliases Service
    class Aliases < BaseService
      DEFAULT_VERSION = 1
      METHODS = [
        { name: :delete,  verb: :delete },
        { name: :convert, verb: :post   }
      ].freeze

      def initialize(client, version = DEFAULT_VERSION)
        super(client, version, 'Aliases', METHODS)
      end
    end
  end
end
