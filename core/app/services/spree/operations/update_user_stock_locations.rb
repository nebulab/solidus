# frozen_string_literal: true

module Spree
  module Operations
    class UpdateUserStockLocations
      def call(user, stock_location_ids, ability)
        user.stock_locations = Spree::StockLocation.
          accessible_by(ability).
          where(id: stock_location_ids) if ability.can?(:manage, Spree::StockLocation)

        Spree::Result.success(user.stock_locations)
      end
    end
  end
end
