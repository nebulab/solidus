# frozen_string_literal: true

module Spree
  # Manage current order when the currency is switched in the frontend
  #
  # It just empties the order, which translates into removing any line item
  # added to the cart.
  class SwitchCurrencyService
    include Dry::Monads[:maybe, :result]

    # @return [Spree::Result]
    def call(order)
      Some(
        order.empty!
      ).to_spree_result
    end
  end
end
