# frozen_string_literal: true

require 'spree/event/listener'

RSpec.describe Spree::Event::Listener do
  describe '#call' do
    it 'returns the result of calling block with given event' do
      listener = described_class.new(pattern: 'foo', block: ->(event) { event[:bar] })

      expect(listener.call(bar: 'bar')).to eq('bar')
    end
  end

  describe '#matches?' do
    it 'return true when given event name matches pattern as a string' do
      listener = described_class.new(pattern: 'foo', block: -> {})

      expect(listener.matches?('foo')).to be(true)
    end

    it 'return true when given event name matches pattern as a regexp' do
      listener = described_class.new(pattern: /oo/, block: -> {})

      expect(listener.matches?('foo')).to be(true)
    end

    it "returns false when given event name doesn't match pattern" do
      listener = described_class.new(pattern: 'foo', block: -> {})

      expect(listener.matches?('bar')).to be(false)
    end

    it "returns false when given event name matches but the listener is unsubscribed from the event" do
      listener = described_class.new(pattern: 'foo', block: -> {})

      listener.unsubscribe('foo')

      expect(listener.matches?('foo')).to be(false)
    end
  end

  describe '#unsubscribe' do
    context 'when event name matches' do
      it "adds an exclusion so that it no longer matches" do
        listener = described_class.new(pattern: 'foo', block: -> {})

        expect(listener.matches?('foo')).to be(true)

        listener.unsubscribe('foo')

        expect(listener.matches?('foo')).to be(false)
      end
    end

    context "when event name doesn't match" do
      it 'does nothing' do
        listener = described_class.new(pattern: 'foo', block: -> {})

        listener.unsubscribe('bar')

        expect(listener.matches?('foo')).to be(true)
        expect(listener.matches?('bar')).to be(false)
      end
    end
  end

  describe '#listeners' do
    it 'returns a list containing only itself' do
      listener = described_class.new(pattern: 'foo', block: -> {})

      expect(listener.listeners).to eq([listener])
    end
  end

  describe '#with_block' do
    it 'returns a new instance of a listener' do
      listener = described_class.new(pattern: 'foo', block: -> {})

      new_listener = listener.with_block(proc {})

      expect(new_listener).not_to eq(listener)
    end

    it 'preserves pattern' do
      listener = described_class.new(pattern: 'foo', block: -> {})

      new_listener = listener.with_block(proc {})

      expect(new_listener.pattern).to eq(listener.pattern)
    end

    it 'preserves exclusions' do
      listener = described_class.new(pattern: 'foo', block: proc {}, exclusions: 'foo')

      new_listener = listener.with_block(proc {})

      expect(new_listener.exclusions).to eq(listener.exclusions)
    end

    it 'switches blocks' do
      listener = described_class.new(pattern: 'foo', block: proc { :old_block }, exclusions: 'foo')

      new_listener = listener.with_block(proc { :new_block })

      expect(new_listener.call(:event)).to eq(:new_block)
    end
  end
end
