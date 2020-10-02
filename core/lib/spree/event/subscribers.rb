# frozen_string_literal: true

module Spree
  module Event
    class Subscribers
      attr_reader :mappings

      def initialize
        @mappings = {}
      end

      def register(subscriber)
        mappings[subscriber.name] ||= {}
      end

      def subscribe_all
        mappings.each_key { |subscriber_name| subscribe(subscriber_name.constantize) }
      end

      def unsubscribe_all
        mappings.each_key { |subscriber_name| unsubscribe(subscriber_name.constantize) }
      end

      private

      def subscribe(subscriber)
        subscriber.event_actions.each do |event_action, event_name|
          subscription = Spree::Event.subscribe(event_name) { |event| subscriber.send(event_action, event) }

          # deprecated mappings, to be removed when Solidus 2.10 is not supported anymore:
          subscriber.send("#{event_action}_handler=", subscription)

          mappings[subscriber.name][event_action] = subscription
        end
      end

      def unsubscribe(subscriber)
        subscriber.event_actions.keys.each do |event_action|
          if (subscription = mappings.dig(subscriber.name, event_action))
            Spree::Event.unsubscribe(subscription)

            mappings[subscriber.name].delete(event_action)
          end
        end
      end
    end
  end
end
