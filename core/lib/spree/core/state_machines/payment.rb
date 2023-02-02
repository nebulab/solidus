# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      # Payments' state machine
      #
      # for each event the following instance methods are dynamically implemented:
      #   #<event_name>
      #   #<event_name>!
      #   #can_<event_name>?
      #
      # for each state the following instance methods are implemented:
      #   #<state_name>?
      #
      module Payment
        extend ActiveSupport::Concern

        included do
          state_machine initial: :checkout do
            event :started_processing do
              transition from: [:failed, :checkout, :pending, :completed, :processing], to: :processing
            end
            event :failure do
              transition from: [:pending, :processing, :failed], to: :failed
            end
            event :pend do
              transition from: [:checkout, :processing, :failed], to: :pending
            end
            event :complete do
              transition from: [:processing, :pending, :checkout], to: :completed
            end
            event :void do
              transition from: [:pending, :processing, :completed, :checkout], to: :void
            end
            event :invalidate do
              transition from: [:checkout], to: :invalid
            end

            after_transition do |payment, transition|
              payment.state_changes.create!(
                previous_state: transition.from,
                next_state: transition.to,
                name: 'payment'
              )
            end
          end
        end
      end
    end
  end
end
