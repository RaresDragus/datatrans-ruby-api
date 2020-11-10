# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Transactions Service
    class Transactions < BaseService
      private

      # @return [Array<Hash>] methods Array of actions and verbs used for requests
      def service_methods
        [
          { name: :init,                       verb: :post  }, { name: :authorize,               verb: :post },
          { name: :authorize_with_transaction, verb: :post  }, { name: :validate,                verb: :post },
          { name: :settle,                     verb: :post  }, { name: :cancel,                  verb: :post },
          { name: :credit,                     verb: :post  }, { name: :credit_with_transaction, verb: :post },
          { name: :secure_fields,              verb: :post  }, { name: :status,                  verb: :get  },
          { name: :update_amount,              verb: :patch }
        ]
      end
    end
  end
end
