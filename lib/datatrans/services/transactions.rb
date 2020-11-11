# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Transactions Service
    class Transactions < BaseService
      private

      # @return [Array<Hash>] An array of actions and verbs used for requests
      def service_methods
        [
          { name: :authorize,                  verb: :post }, { name: :secure_fields, verb: :post  },
          { name: :authorize_with_transaction, verb: :post }, { name: :settle,        verb: :post  },
          { name: :cancel,                     verb: :post }, { name: :status,        verb: :get   },
          { name: :credit,                     verb: :post }, { name: :validate,      verb: :post  },
          { name: :credit_with_transaction,    verb: :post }, { name: :update_amount, verb: :patch },
          { name: :init,                       verb: :post }
        ]
      end
    end
  end
end
