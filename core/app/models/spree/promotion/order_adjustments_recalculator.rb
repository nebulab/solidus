# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base

    # This class encapsulates all the things the promotion system does to
    # an order. It is called from the `Spree::OrderUpdater` before taxes are
    # calculated, such that taxes always respect promotions.

    # This class iterates over all existing promotion adjustments and recalculates
    # their amount and eligibility using their adjustment source.
    class OrderAdjustmentsRecalculator
      def initialize(order)
        @order = order
      end

      def call

        # Simplified version of the algorithm:
        # There's no categories, priority or stacking yet.
        
        order.running_total = 0
        
        all_items = line_items + shipments + [order]
        possible_promotions_for_order_and_items = Hash.new { |h, k| h[k] = [] } # TODO: check other syntax
        all_items.map(&:adjustments).flatten.select(&:promotion?).each do |adjustment|
          possible_promotions_for_order_and_items[adjustment.source.promotion] << adjustment.adjustable
        end
        
        possible_promotions_for_order_and_items.each do |promotion, items|
          items.each do |item|
            if item.is_a? Spree::Order
              item.running_total += item.line_items.map(&:running_total).sum
              item.running_total += item.shipments.map(&:running_total).sum
            else
              item.running_total ||= 0
            end
            # TODO: only check the eligible adjustments?
            adjustment = item.adjustments.select(&:promotion?).find { |a| a.source.promotion == promotion }
            item.running_total += adjustment.source.compute_amount(item)
          end
        end        
        
        # possible_promotions_for_line_items = Hash.new { |h, k| h[k] = [] }
        # line_items.map(&:adjustments).flatten.select(&:promotion?).each do |adjustment|
        #   possible_promotions_for_line_items[adjustment.source.promotion] << adjustment.adjustable
        # end

        # possible_promotions_for_shipments = Hash.new { |h, k| h[k] = [] }
        # shipments.map(&:adjustments).flatten.select(&:promotion?).each do |adjustment|
        #   possible_promotions_for_shipments[adjustment.source.promotion] << adjustment.adjustable
        # end

        # possible_promotions_for_order = Hash.new { |h, k| h[k] = [] }
        # order.adjustments.select(&:promotion?).each do |adjustment|
        #   possible_promotions_for_order[adjustment.source.promotion] << adjustment.adjustable
        # end

        # possible_promotions_for_line_items.each do |promotion, items|
        #   items.each do |item|
        #     item.running_total ||= 0
        #     # TODO: only check the eligible adjustments?
        #     adjustment = item.adjustments.select(&:promotion?).find { |a| a.source.promotion == promotion }
        #     item.running_total += adjustment.source.compute_amount(item)
        #   end
        # end

        # order.running_total += possible_promotions_for_line_items.values.flatten.sum(&:running_total)

        # possible_promotions_for_shipments.each do |promotion, items|
        #   items.each do |item|
        #     item.running_total ||= 0
        #     # TODO: only check the eligible adjustments?
        #     adjustment = item.adjustments.select(&:promotion?).find { |a| a.source.promotion == promotion }
        #     item.running_total += adjustment.source.compute_amount(item)
        #   end
        # end

        # order.running_total += possible_promotions_for_shipments.values.flatten.sum(&:running_total)

        # possible_promotions_for_order.each do |promotion, _items|
        #   adjustment = order.adjustments.select(&:promotion?).find { |a| a.source.promotion == promotion }
        #   order.running_total += adjustment.source.compute_amount(order)
        # end


        debugger
        order.promo_total = order.running_total



        
        

        # all_items = line_items + shipments
        # all_items.each do |item|
        #   promotion_adjustments = item.adjustments.select(&:promotion?)

        #   promotion_adjustments.each { |adjustment| recalculate(adjustment) }
        #   Spree::Config.promotion_chooser_class.new(promotion_adjustments).update

        #   item.promo_total = promotion_adjustments.select(&:eligible?).sum(&:amount)
        # end
        # # Update and select the best promotion adjustment for the order.
        # # We don't update the order.promo_total yet. Order totals are updated later
        # # in #update_adjustment_total since they include the totals from the order's
        # # line items and/or shipments.
        # order_promotion_adjustments = order.adjustments.select(&:promotion?)
        # order_promotion_adjustments.each { |adjustment| recalculate(adjustment) }
        # Spree::Config.promotion_chooser_class.new(order_promotion_adjustments).update

        # order.promo_total = all_items.sum(&:promo_total) +
        #                     order_promotion_adjustments.
        #                       select(&:eligible?).
        #                       select(&:promotion?).
        #                       sum(&:amount)
        order
      end

      private

      attr_reader :order
      delegate :line_items, :shipments, to: :order

      # Recalculate and persist the amount from this adjustment's source based on
      # the adjustable ({Order}, {Shipment}, or {LineItem})
      #
      # If the adjustment has no source (such as when created manually from the
      # admin) or is closed, this is a noop.
      #
      # @return [BigDecimal] New amount of this adjustment
      def recalculate(adjustment)
        if adjustment.finalized?
          return adjustment.amount
        end

        # If the adjustment has no source, do not attempt to re-calculate the
        # amount.
        # Some scenarios where this happens:
        #   - Adjustments that are manually created via the admin backend
        #   - PromotionAction adjustments where the PromotionAction was deleted
        #     after the order was completed.
        if adjustment.source.present?
          adjustment.amount = adjustment.source.compute_amount(adjustment.adjustable)

          adjustment.eligible = calculate_eligibility(adjustment)

          # Persist only if changed
          # This is only not a save! to avoid the extra queries to load the order
          # (for validations) and to touch the adjustment.
          adjustment.update_columns(eligible: adjustment.eligible, amount: adjustment.amount, updated_at: Time.current) if adjustment.changed?
        end
        adjustment.amount
      end

      # Calculates based on attached promotion (if this is a promotion
      # adjustment) whether this promotion is still eligible.
      # @api private
      # @return [true,false] Whether this adjustment is eligible
      def calculate_eligibility(adjustment)
        if !adjustment.finalized? && adjustment.source
          adjustment.source.promotion.eligible?(adjustment.adjustable, promotion_code: adjustment.promotion_code)
        else
          adjustment.eligible?
        end
      end
    end
  end
end
