# frozen_string_literal: true

module Spree
  module Event
    # A triggered event
    #
    # An instance of it is automatically created on {Spree::Event.fire}.  The
    # instance is consumed on {Spree::Event.subscribe}.
    #
    # @example
    #   Spree::Event.fire 'event_name', foo: 'bar'
    #   Spree::Event.subscribe 'event_name' do |event|
    #     puts event.payload['foo'] #=> 'bar'
    #   end
    class Event
      # Hash with the options given to {Spree::Event.fire}
      #
      # @return [Hash]
      attr_reader :payload

      # Creation time for the {Event} instance
      #
      # @return [Time]
      attr_reader :time

      # Relevant stack location for the creation of the {Event}
      #
      # It's set on initialization. It defaults to 4 levels up the stack to
      # go through:
      #
      #   - The {#initialize} method.
      #   - The adapter `#fire` method (for instance
      #   {Spree::Events::Adapters#fire}).
      #   - {Spree::Event.fire}.
      #
      # @return [Thread::Backtrace::Location]
      attr_reader :caller_location

      # @api private
      def initialize(payload: {}.freeze, caller_location: caller_locations(4, 1)[0])
        @payload = payload
        @time = Time.now
        @caller_location = caller_location
      end
    end
  end
end
