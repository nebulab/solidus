# frozen_string_literal: true

require 'spec_helper'
require 'spree/event/adapters/default'

module Spree
  module Event
    module Adapters
      RSpec.describe Default do
        describe '#fire' do
          it 'executes listeners subscribed as a string to the event name' do
            bus = described_class.new
            dummy = Class.new do
              attr_reader :run

              def initialize
                @run = false
              end

              def toggle
                @run = true
              end
            end.new
            bus.subscribe('foo') { dummy.toggle }

            bus.fire 'foo'

            expect(dummy.run).to be(true)
          end

          it 'executes listeners subscribed as a regexp to the event name' do
            bus = described_class.new
            dummy = Class.new do
              attr_reader :run

              def initialize
                @run = false
              end

              def toggle
                @run = true
              end
            end.new
            bus.subscribe(/oo/) { dummy.toggle }

            bus.fire 'foo'

            expect(dummy.run).to be(true)
          end

          it "doesn't execute listeners not subscribed to the event name" do
            bus = described_class.new
            dummy = Class.new do
              attr_reader :run

              def initialize
                @run = false
              end

              def toggle
                @run = true
              end
            end.new
            bus.subscribe('bar') { dummy.toggle }

            bus.fire 'foo'

            expect(dummy.run).to be(false)
          end

          it "doesn't execute listeners partially matching as a string" do
            bus = described_class.new
            dummy = Class.new do
              attr_reader :run

              def initialize
                @run = false
              end

              def toggle
                @run = true
              end
            end.new
            bus.subscribe('bar') { dummy.toggle }

            bus.fire 'barr'

            expect(dummy.run).to be(false)
          end

          it 'binds given options to the subscriber as the event payload' do
            bus = described_class.new
            dummy = Class.new do
              attr_accessor :box
            end.new
            bus.subscribe('foo') { |event| dummy.box = event.payload[:box] }

            bus.fire 'foo', box: 'foo'

            expect(dummy.box).to eq('foo')
          end
        end

        describe '#subscribe' do
          it 'registers to matching event as string' do
            bus = described_class.new

            block = ->{}
            bus.subscribe('foo', &block)

            expect(bus.listeners.first.block.object_id).to eq(block.object_id)
          end

          it 'registers to matching event as regexp' do
            bus = described_class.new

            block = ->{}
            bus.subscribe(/oo/, &block)

            expect(bus.listeners.first.block.object_id).to eq(block.object_id)
          end

          it 'returns a listener object with given block' do
            bus = described_class.new

            listener = bus.subscribe('foo') { 'bar' }

            expect(listener.block.call).to eq('bar')
          end
        end

        describe '#unsubscribe' do
          context 'when given a listener' do
            it 'unsubscribes given listener' do
              bus = described_class.new
              dummy = Class.new do
                attr_reader :run

                def initialize
                  @run = false
                end

                def toggle
                  @run = true
                end
              end.new
              listener = bus.subscribe('foo') { dummy.toggle }

              bus.unsubscribe listener
              bus.fire 'foo'

              expect(dummy.run).to be(false)
            end
          end

          context 'when given an event name' do
            it 'unsubscribes all listeners for that event' do
              bus = described_class.new
              dummy = Class.new do
                attr_reader :run

                def initialize
                  @run = false
                end

                def toggle
                  @run = true
                end
              end.new

              bus.subscribe('foo') { dummy.toggle }
              bus.unsubscribe 'foo'
              bus.fire 'foo'

              expect(dummy.run).to be(false)
            end
          end

          it 'unsubscribes listeners that match event with a regexp' do
            bus = described_class.new
            dummy = Class.new do
              attr_reader :run

              def initialize
                @run = false
              end

              def toggle
                @run = true
              end
            end.new
            bus.subscribe(/foo/) { dummy.toggle }
            bus.unsubscribe 'foo'

            bus.fire 'foo'

            expect(dummy.run).to be(false)
          end

          it "doesn't unsubscribe listeners for other events" do
            bus = described_class.new
            dummy = Class.new do
              attr_reader :run

              def initialize
                @run = false
              end

              def toggle
                @run = true
              end
            end.new

            bus.subscribe('foo') { dummy.toggle }
            bus.unsubscribe 'bar'
            bus.fire 'foo'

            expect(dummy.run).to be(true)
          end

          it 'can resubscribe other listeners to the same event' do
            bus = described_class.new
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

            bus.subscribe('foo') { dummy1.toggle }
            bus.unsubscribe 'foo'
            bus.subscribe('foo') { dummy2.toggle }
            bus.fire 'foo'

            expect(dummy1.run).to be(false)
            expect(dummy2.run).to be(true)
          end
        end

        describe '#with_listeners' do
          it 'returns a new instance with given listeners' do
            bus = described_class.new
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
            listener1 = bus.subscribe('foo') { dummy1.toggle }
            listener2 = bus.subscribe('foo') { dummy2.toggle }
            listener3 = bus.subscribe('foo') { dummy3.toggle }

            new_bus = bus.with_listeners([listener1, listener2])
            new_bus.fire('foo')

            expect(new_bus).not_to eq(bus)
            expect(new_bus.listeners).to match_array([listener1, listener2])
            expect(dummy1.run).to be(true)
            expect(dummy2.run).to be(true)
            expect(dummy3.run).to be(false)
          end
        end

        describe '#with_injected_listeners' do
          it 'returns as firt element a new instance with injected listeners' do
            bus = described_class.new
            dummy1, dummy2, dummy3 = Array.new(3) do
              Class.new do
                attr_accessor :field
              end.new
            end
            listener1 = bus.subscribe('foo') { dummy1.field = 'default' }
            listener2 = bus.subscribe('foo') { dummy2.field = 'default' }
            listener3 = bus.subscribe('foo') { dummy3.field = 'default' }
            injection1 = proc { dummy1.field = 'injected' }
            injection2 = proc { dummy2.field = 'injected' }

            new_bus, _mapping = bus.with_injected_listeners(listener1 => injection1, listener2 => injection2)
            new_bus.fire('foo')

            expect(new_bus).not_to eq(bus)
            expect(dummy1.field).to eq('injected')
            expect(dummy2.field).to eq('injected')
            expect(dummy3.field).to eq('default')
          end

          it 'returns as second element the mapping between original listeners and new ones' do
            bus = described_class.new
            dummy1, dummy2 = Array.new(2) do
              Class.new do
                attr_accessor :field
              end.new
            end
            listener1 = bus.subscribe('foo') { dummy1.field = 'default' }
            listener2 = bus.subscribe('foo') { dummy2.field = 'default' }
            injection1 = proc { dummy1.field = 'injected' }
            injection2 = proc { dummy2.field = 'injected' }

            _new_bus, mapping = bus.with_injected_listeners(listener1 => injection1, listener2 => injection2)

            expect(dummy1.field).to be_nil
            expect(dummy2.field).to be_nil

            mapping[listener1].call(:event)
            mapping[listener2].call(:event)

            expect(dummy1.field).to eq('injected')
            expect(dummy2.field).to eq('injected')
          end
        end
      end
    end
  end
end
