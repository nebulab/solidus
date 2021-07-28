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
      listener = Spree::Event.subscribe('foo') { dummy.toggle }

      Spree::Event.performing_only do
        Spree::Event.fire('foo')
      end

      expect(dummy.run).to be(false)
    ensure
      Spree::Event.unsubscribe(listener)
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
      listener = Spree::Event.subscribe('foo') { dummy.toggle }

      Spree::Event.performing_only do
        Spree::Event.performing_only(listener) do
          Spree::Event.fire('foo')
        end
      end

      expect(dummy.run).to be(true)
    ensure
      Spree::Event.unsubscribe(listener)
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
      listener = Spree::Event.subscribe('foo') { dummy.toggle }

      Spree::Event.silenced do
        Spree::Event.fire('foo')
      end

      expect(dummy.run).to be(false)
    ensure
      Spree::Event.unsubscribe(listener)
    end
  end

  describe '#inject_listeners' do
    before { Spree::Event.enable_test_interface }

    it 'switches listeners for the duration of the block' do
      dummy1, dummy2, dummy3 = Array.new(3) do
        Class.new do
          attr_accessor :field
        end.new
      end
      listener1 = Spree::Event.subscribe('foo') { dummy1.field = 'default' }
      listener2 = Spree::Event.subscribe('foo') { dummy2.field = 'default' }
      listener3 = Spree::Event.subscribe('foo') { dummy3.field = 'default' }
      injection1 = proc { dummy1.field = 'injected' }
      injection2 = proc { dummy2.field = 'injected' }

      Spree::Event.inject_listeners(listener1 => injection1, listener2 => injection2) do
        Spree::Event.fire('foo')
      end

      expect(dummy1.field).to eq('injected')
      expect(dummy2.field).to eq('injected')
      expect(dummy3.field).to eq('default')
    ensure
      Spree::Event.unsubscribe(listener1)
      Spree::Event.unsubscribe(listener2)
      Spree::Event.unsubscribe(listener3)
    end

    it 'performs again the original listener when the block is over' do
      dummy = Class.new do
        attr_accessor :field
      end.new
      listener = Spree::Event.subscribe('foo') { dummy.field = 'default' }
      injection = proc { dummy.field = 'injected' }

      Spree::Event.inject_listeners(listener => injection) do
        Spree::Event.fire('foo')
      end

      expect(dummy.field).to eq('injected')

      Spree::Event.fire('foo')

      expect(dummy.field).to eq('default')
    ensure
      Spree::Event.unsubscribe(listener)
    end

    it 'yields the mapping between original listeners and new injected listeners' do
      dummy = Class.new do
        attr_accessor :field
      end.new
      listener = Spree::Event.subscribe('foo') { dummy.field = 'default' }
      injection = proc { dummy.field = 'injected' }

      Spree::Event.inject_listeners(listener => injection) do |mapping|
        Spree::Event.unsubscribe mapping[listener]
        Spree::Event.fire('foo')
      end

      expect(dummy.field).to be_nil
    ensure
      Spree::Event.unsubscribe(listener)
    end
  end
end
