require_dependency 'spree/returns_calculator'

module Spree
  module Calculator::Returns
    class DefaultRefundAmount < ReturnsCalculator
      def compute(return_item)
        return 0.0.to_d if return_item.part_of_exchange?
        round_to_two_places(weighted_total_amount(return_item.inventory_unit))
      end

      private

      def weighted_total_amount(inventory_unit)
        weighted_order_adjustment_amount(inventory_unit) + weighted_line_item_amount(inventory_unit)
      end

      def weighted_order_adjustment_amount(inventory_unit)
        inventory_unit.order.adjustments.eligible.non_tax.sum(:amount) * percentage_of_order_total(inventory_unit)
      end

      def weighted_line_item_amount(inventory_unit)
        inventory_unit.line_item.discounted_amount / quantity_of_line_item(inventory_unit)
      end

      def percentage_of_order_total(inventory_unit)
        return 0.0 if inventory_unit.order.discounted_item_amount.zero?
        weighted_line_item_amount(inventory_unit) / inventory_unit.order.discounted_item_amount
      end

      def quantity_of_line_item(inventory_unit)
        BigDecimal.new(inventory_unit.line_item.quantity)
      end
    end
  end
end
