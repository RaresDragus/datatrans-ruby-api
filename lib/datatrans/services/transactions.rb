# frozen_string_literal: true

module Datatrans
  module Services
    # Model wraps the Datatrans Transactions Service
    class Transactions < BaseService
      DEFAULT_VERSION = 1
      METHODS = [
        { name: :init,                       verb: :post  },
        { name: :authorize,                  verb: :post  },
        { name: :authorize_with_transaction, verb: :post  },
        { name: :validate,                   verb: :post  },
        { name: :settle,                     verb: :post  },
        { name: :cancel,                     verb: :post  },
        { name: :credit,                     verb: :post  },
        { name: :credit_with_transaction,    verb: :post  },
        { name: :secure_fields,              verb: :post  },
        { name: :status,                     verb: :get   },
        { name: :update_amount,              verb: :patch }
      ].freeze

      def initialize(client, version = DEFAULT_VERSION)
        super(client, version, 'Transactions', METHODS)
      end
    end
  end
end
