module Spree
  class Order
    module Interactors
      class Finalizer
        include EventedOrganizer

        class FinalizeAdjustments
          include EventedInteractor

          delegate :order, to: :context

          def call
            # lock all adjustments (coupon promotions, etc.)
            order.all_adjustments.each(&:finalize!)

            # update payment and shipment(s) states, and save
            order.updater.update_payment_state
          end
        end

        class FinalizeShipments
          include EventedInteractor

          delegate :order, to: :context

          def call
            order.shipments.each do |shipment|
              shipment.update_state
              shipment.finalize!
            end

            order.updater.update_shipment_state
          end
        end

        class RunHooks
          include EventedInteractor

          delegate :order, to: :context

          def call
            order.save!
            order.updater.run_hooks
            order.touch :completed_at
          end
        end

        organize FinalizeAdjustments, FinalizeShipments, RunHooks

        def event_name_success
          'order_finalized'
        end

        def event_subject
          context.order
        end
      end
    end
  end
end
