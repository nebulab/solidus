# frozen_string_literal: true

module Spree
  module Event
    # This module simplifies adding and removing subscriptions to {Spree::Event} events.
    # Here's a complete example:
    #   module EmailSender
    #     include Spree::Event::Subscriber
    #
    #     event_action :order_finalized
    #     event_action :confirm_reimbursement, event_name: :reimbursement_reimbursed
    #
    #     def order_finalized(event)
    #       Mailer.send_email(event.payload[:order])
    #     end
    #
    #     def confirm_reimbursement(event)
    #       Mailer.send_email(event.payload[:reimbursement])
    #     end
    #   end
    #
    #  EmailSender.subscribe!
    module Subscriber
      def self.included(base)
        base.extend base

        base.mattr_accessor :event_actions
        base.event_actions = {}

        Spree::Event.subscribers[base.name] ||= {}
      end

      # Declares a method name in the including module that can be subscribed/unsubscribed
      # to an event.
      #
      # @param method_name [String, Symbol] the method that will be called when the subscribed event is fired
      # @param event_name [String, Symbol] the name of the event to be subscribed
      #
      # @example Declares 'send_email' as an event action that can subscribe the event 'order_finalized'
      #   module EmailSender
      #     event_action :send_email, event_name: :order_finalized
      #
      #     def send_email(event)
      #       Mailer.send_email(event.payload[:order])
      #     end
      #   end
      #
      # @example Same as above, but the method name is same as the event name:
      #   module EmailSender
      #     event_action :order_completed
      #
      #     def order_completed(event)
      #       Mailer.send_email(event.payload[:order])
      #     end
      #   end
      def event_action(method_name, event_name: nil)
        mattr_writer "#{method_name}_handler"

        define_method "#{method_name}_handler" do
          Spree::Deprecation.warn("#{name}.#{method_name}_handler and #{name}.#{method_name}_handler= from the old events mapping interface are deprecated. Please use the new mapping stored in Spree::Event.subscribers.", caller)

          class_variable_get("@@#{method_name}_handler")
        end

        event_actions[method_name] = (event_name || method_name).to_s
      end

      # Subscribes all declared event actions to their events. Only actions that are subscribed
      # will be called when their event fires.
      #
      # @example subscribe all event actions for module 'EmailSender'
      #    EmailSender.subscribe!
      def subscribe!
        unsubscribe!
        event_actions.each do |event_action, event_name|
          subscription = Spree::Event.subscribe(event_name) { |event| send event_action, event }
          # deprecated mappings, to be removed when Solidus 2.10 is not supported anymore:
          send "#{event_action}_handler=", subscription

          Spree::Event.subscribers[name][event_action] = subscription
        end
      end

      # Unsubscribes all declared event actions from their events. This means that when an event
      # fires then none of its unsubscribed event actions will be called.
      # @example unsubscribe all event actions for module 'EmailSender'
      #    EmailSender.unsubscribe!
      def unsubscribe!
        event_actions.keys.each do |event_action|
          if (subscription = Spree::Event.subscribers.dig(name, event_action))
            Spree::Event.unsubscribe(subscription)
            Spree::Event.subscribers[name].delete(event_action)
          end
        end
      end
    end
  end
end
