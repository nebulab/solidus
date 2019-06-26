# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      module BaseReturnAuthorization
        extend ActiveSupport::Concern

        included do
          state_machine initial: :authorized do
            before_transition to: :canceled, do: :cancel_return_items

            event :cancel do
              transition to: :canceled, from: :authorized, if: lambda { |return_authorization| return_authorization.can_cancel_return_items? }
            end
          end
        end
      end
    end
  end
end
