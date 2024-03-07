# frozen_string_literal: true

module Spree
  module Stock
    class Quantifier
      attr_reader :stock_items

      # @param [Variant] variant The variant to check inventory for.
      # @param [StockLocation, Integer] stock_location_or_id
      #        The stock_location or stock location ID to check inventory in.
      #        If unspecified it will check inventory in all available StockLocations
      def initialize(variant, stock_location_or_id = nil)
        @variant = variant
        @stock_location_or_id = stock_location_or_id
        @stock_items = variant_stock_items
      end

      # Returns the total number of inventory units on hand for the variant.
      #
      # @return [Fixnum] number of inventory units on hand, or infinity if
      #   inventory is not tracked on the variant.
      def total_on_hand
        if variant.should_track_inventory?
          stock_items.sum(&:count_on_hand)
        else
          Float::INFINITY
        end
      end

      # Checks if any of its stock items are backorderable.
      #
      # @return [Boolean] true if any stock items are backorderable
      def backorderable?
        stock_items.any?(&:backorderable)
      end

      # Checks if it is possible to supply a given number of units.
      #
      # @param required [Fixnum] the number of required stock units
      # @return [Boolean] true if we have the required amount on hand or the
      #   variant is backorderable, otherwise false
      def can_supply?(required)
        total_on_hand >= required || backorderable?
      end

      def positive_stock
        return unless stock_location

        on_hand = stock_location.count_on_hand(variant)
        on_hand.positive? ? on_hand : 0
      end

      private

      attr_reader :variant, :stock_location_or_id

      def stock_location
        @stock_location ||= if stock_location_or_id.is_a?(Spree::StockLocation)
          stock_location_or_id
        else
          Spree::StockLocation.find_by(id: stock_location_or_id)
        end
      end

      def variant_stock_items
        variant.stock_items.select do |stock_item|
          if stock_location_or_id
            stock_item.stock_location == stock_location_or_id ||
              stock_item.stock_location_id == stock_location_or_id
          else
            stock_item.stock_location.active?
          end
        end
      end
    end
  end
end
