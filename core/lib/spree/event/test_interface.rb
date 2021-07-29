# frozen_string_literal: true

require 'spree/event'

module Spree
  module Event
    # Test helpers for {Spree::Event}
    #
    # This module defines test helpers methods that are made available to
    # {Spree::Event} when {Spree::Event.enable_test_interface} is called.
    module TestInterface
      # Perform only given listeners for the duration of the block
      #
      # Temporarily deactivate all subscribed listeners and listen only to the
      # provided ones for the duration of the block.
      #
      # @example
      #   Spree::Event.enable_test_interface
      #
      #   listener1 = Spree::Event.subscribe('foo') { do_something }
      #   listener2 = Spree::Event.subscribe('foo') { do_something_else }
      #
      #   Spree::Event.performing_only(listener1) do
      #     Spree::Event.fire('foo') # This will run only `listener1`
      #   end
      #
      #   Spree::Event.fire('foo') # This will run both `listener1` & `listener2`
      #
      # {Spree::Event::Subscriber} modules can also be given to unsubscribe from
      # all listeners generated from it:
      #
      # @example
      #   Spree::Event.performing_only(EmailSubscriber) {}
      #
      # You can gain more fine-grained control thanks to
      # {Spree::Event::Subscribe#listeners}:
      #
      # @example
      #   Spree::Event.performing_only(EmailSubscriber.listeners('order_finalized') {}
      #
      # You can mix different ways of specifying listeners without problems:
      #
      # @example
      #   Spree::Event.performing_only(EmailSubscriber, listener1) {}
      #
      # @param listeners_and_subscribers [Spree::Event::Listener,
      # Array<Spree::Event::Listener>, Spree::Event::Subscriber]
      # @yield While the block executes only provided listeners will run
      def performing_only(*listeners_and_subscribers)
        old_adapter = default_adapter
        listeners = listeners_and_subscribers.flatten.map(&:listeners)
        Spree::Config.events.adapter = old_adapter.with_listeners(listeners.flatten)
        yield
        Spree::Config.events.adapter = old_adapter
      end

      # Perform no listeners for the duration of the block
      #
      # It's a specialized version of {#performing_only} that provides no
      # listeners.
      #
      # @yield While the block executes no listeners will run
      #
      # @see Spree::Event::TestInterface#performing_only
      def silenced(&block)
        performing_only(&block)
      end

      # Unregisters a previously registered event
      #
      # @param [String, Symbol] event_name
      def unregister(event_name)
        registry.unregister(normalize_name(event_name))
      end
    end

    # Adds test methods to {Spree::Event}
    #
    # @raise [RuntimeError] when {Spree::Event::Configuration#adapter} is set to
    # the legacy adapter {Spree::Event::Adapters::ActiveSupportNotifications}.
    def enable_test_interface
      raise <<~MSG if legacy_adapter?(default_adapter)
        Spree::Event's test interface is not supported when using the deprecated
        adapter 'Spree::Event::Adapters::ActiveSupportNotifications'.
      MSG

      extend(TestInterface)
    end
  end
end
