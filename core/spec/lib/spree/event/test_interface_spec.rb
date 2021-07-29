# frozen_string_literal: true

require 'rails_helper'
require 'spree/event/test_interface'

RSpec.describe Spree::Event::TestInterface do
  describe '#enable_test_interface' do
    context 'when using the legacy adapter' do
      it 'raises an error' do
        adapter = Spree::Config.events.adapter
        Spree::Config.events.adapter = Spree::Event::Adapters::ActiveSupportNotifications

        expect {
          Spree::Event.enable_test_interface
        }.to raise_error(/test interface is not supported/)
      ensure
        Spree::Config.events.adapter = adapter
      end
    end
  end

  describe '#performing_only' do
    before { Spree::Event.enable_test_interface }

    it 'only performs given listeners for the duration of the block' do
      dummy1, dummy2, dummy3 = Array.new(3) do
        Class.new do
          attr_reader :run

          def initialize
            @run = false
          end

          def toggle
            @run = true
          end
        end.new
      end
      Spree::Event.register('foo')
      listener1 = Spree::Event.subscribe('foo') { dummy1.toggle }
      listener2 = Spree::Event.subscribe('foo') { dummy2.toggle }
      listener3 = Spree::Event.subscribe('foo') { dummy3.toggle }

      Spree::Event.performing_only(listener1, listener2) do
        Spree::Event.fire('foo')
      end

      expect(dummy1.run).to be(true)
      expect(dummy2.run).to be(true)
      expect(dummy3.run).to be(false)
    ensure
      Spree::Event.unsubscribe(listener1)
      Spree::Event.unsubscribe(listener2)
      Spree::Event.unsubscribe(listener3)
      Spree::Event.unregister('foo')
    end

    it 'performs again all the listeners once the block is done' do
      dummy1, dummy2 = Array.new(2) do
        Class.new do
          attr_reader :run

          def initialize
            @run = false
          end

          def toggle
            @run = true
          end
        end.new
      end
      Spree::Event.register('foo')
      listener1 = Spree::Event.subscribe('foo') { dummy1.toggle }
      listener2 = Spree::Event.subscribe('foo') { dummy2.toggle }

      Spree::Event.performing_only(listener1) do
        Spree::Event.fire('foo')
      end

      expect(dummy1.run).to be(true)
      expect(dummy2.run).to be(false)

      Spree::Event.fire('foo')

      expect(dummy2.run).to be(true)
    ensure
      Spree::Event.unsubscribe(listener1)
      Spree::Event.unsubscribe(listener2)
      Spree::Event.unregister('foo')
    end

    it 'can extract listeners from a subscriber module' do
      dummy1, dummy2 = Array.new(2) do
        Class.new do
          attr_reader :run

          def initialize
            @run = false
          end

          def toggle
            @run = true
          end
        end.new
      end
      Spree::Event.register('foo')
      Subscriber1 = Module.new do
        include Spree::Event::Subscriber

        event_action :foo

        def foo(event)
          event.payload[:dummy1].toggle
        end
      end
      Subscriber2 = Module.new do
        include Spree::Event::Subscriber

        event_action :foo

        def foo(event)
          event.payload[:dummy2].toggle
        end
      end
      Spree::Event.subscriber_registry.register(Subscriber1)
      Spree::Event.subscriber_registry.register(Subscriber2)
      [Subscriber1, Subscriber2].map(&:activate)

      Spree::Event.performing_only(Subscriber1) do
        Spree::Event.fire('foo', dummy1: dummy1, dummy2: dummy2)
      end

      expect(dummy1.run).to be(true)
      expect(dummy2.run).to be(false)
    ensure
      Spree::Event.subscriber_registry.deactivate_subscriber(Subscriber1)
      Spree::Event.subscriber_registry.deactivate_subscriber(Subscriber2)
      Spree::Event.unregister('foo')
    end

    it 'can mix listeners and array of listeners' do
      dummy1, dummy2 = Array.new(2) do 
        Class.new do
          attr_reader :run

          def initialize
            @run = false
          end

          def toggle
            @run = true
          end
        end.new
      end
      Spree::Event.register('foo')
      listener = Spree::Event.subscribe('foo') { dummy1.toggle }
      Subscriber = Module.new do
        include Spree::Event::Subscriber

        event_action :foo

        def foo(event)
          event.payload[:dummy2].toggle
        end
      end
      Spree::Event.subscriber_registry.register(Subscriber)
      Subscriber.activate

      Spree::Event.performing_only(listener, Subscriber) do
        Spree::Event.fire('foo', dummy2: dummy2)
      end

      expect(dummy1.run).to be(true)
      expect(dummy2.run).to be(true)
    ensure
      Spree::Event.unsubscribe(listener)
      Spree::Event.subscriber_registry.deactivate_subscriber(Subscriber)
      Spree::Event.unregister('foo')
    end

    it 'can perform no listener at all' do
      dummy = Class.new do
        attr_reader :run

        def initialize
          @run = false
        end

        def toggle
          @run = true
        end
      end.new
      Spree::Event.register('foo')
      listener = Spree::Event.subscribe('foo') { dummy.toggle }

      Spree::Event.performing_only do
        Spree::Event.fire('foo')
      end

      expect(dummy.run).to be(false)
    ensure
      Spree::Event.unsubscribe(listener)
      Spree::Event.unregister('foo')
    end

    it 'can override through an inner call' do
      dummy = Class.new do
        attr_reader :run

        def initialize
          @run = false
        end

        def toggle
          @run = true
        end
      end.new
      Spree::Event.register('foo')
      listener = Spree::Event.subscribe('foo') { dummy.toggle }

      Spree::Event.performing_only do
        Spree::Event.performing_only(listener) do
          Spree::Event.fire('foo')
        end
      end

      expect(dummy.run).to be(true)
    ensure
      Spree::Event.unsubscribe(listener)
      Spree::Event.unregister('foo')
    end
  end

  describe '#silenced' do
    before { Spree::Event.enable_test_interface }

    it 'performs no listener for the duration of the block' do
      dummy = Class.new do
        attr_reader :run

        def initialize
          @run = false
        end

        def toggle
          @run = true
        end
      end.new
      Spree::Event.register('foo')
      listener = Spree::Event.subscribe('foo') { dummy.toggle }

      Spree::Event.silenced do
        Spree::Event.fire('foo')
      end

      expect(dummy.run).to be(false)
    ensure
      Spree::Event.unsubscribe(listener)
      Spree::Event.unregister('foo')
    end
  end

  describe '#unregister_event' do
    before { Spree::Event.enable_test_interface }

    it 'unregisters an event from the registry' do
      Spree::Event.register('foo')

      Spree::Event.unregister('foo')

      expect {
        Spree::Event.fire('foo')
      }.to raise_error(/not registered/)
    end

    it 'coercers names given as symbol' do
      Spree::Event.register('foo')

      Spree::Event.unregister(:foo)

      expect {
        Spree::Event.fire('foo')
      }.to raise_error(/not registered/)
    end
  end
end
