# frozen_string_literal: true

require 'spec_helper'
require 'spree/event'

RSpec.describe Spree::Event::SubscriberRegistry do
  module M
    include Spree::Event::Subscriber

    event_action :event_name

    def event_name(event)
      # code that handles the event
    end
  end

  let(:subscriber_registry) { described_class.new }
  let(:asn_subscription) { double }

  before { allow(Spree::Event).to receive(:subscribe).and_return(asn_subscription) }
  before { allow(Spree::Event).to receive(:unsubscribe).and_return(asn_subscription) }

  describe '#register' do
    subject { subscriber_registry.register(M) }

    it 'adds the subscriber to the mappings as an empty array' do
      expect { subject }.to change { subscriber_registry.to_h['M'] }.from(nil).to({})
    end
  end

  describe '#activate_all_subscribers' do
    subject { subscriber_registry.activate_all_subscribers }

    context 'When the subscriber was not registrered' do
      it 'does not add the subscriber to the mappings' do
        expect { subject }.not_to change { subscriber_registry.to_h['M'] }
      end
    end

    context 'when the subscriber was registered' do
      before { subscriber_registry.register(M) }

      it 'adds the subscriber to the mappings' do
        expect { subject }.to change { subscriber_registry.to_h['M'] }.to({ event_name: asn_subscription })
      end
    end
  end

  describe '#deactivate_all_subscribers' do
    subject { subscriber_registry.deactivate_all_subscribers }

    context 'when the subscriber was not registered' do
      it 'does not change the mappings' do
        expect { subject }.not_to change { subscriber_registry.to_h }
      end
    end

    context 'when the subscriber was registered' do
      before { subscriber_registry.register(M) }

      context 'when the subscriber was not subscribed' do
        it 'does not change the mappings' do
          expect { subject }.not_to change { subscriber_registry.to_h }
        end
      end

      context 'when the subscriber was subscribed' do
        before { subscriber_registry.activate_all_subscribers }

        it 'removes the subscription from the mappings' do
          expect { subject }.to change { subscriber_registry.to_h['M'] }.to({})
        end
      end
    end
  end

  describe '.require_subscriber_files' do
    let(:susbcribers_dir) { Rails.root.join('app', 'subscribers', 'spree') }

    def create_subscriber_file(constant_name)
      FileUtils.mkdir_p(susbcribers_dir)
      File.open File.join(susbcribers_dir, "#{constant_name.underscore}.rb"), 'w' do |f|
        f.puts "module Spree::#{constant_name}; include Spree::Event::Subscriber; end"
      end
    end

    after { FileUtils.rm_rf(susbcribers_dir) }

    context 'when Spree::Config.events.autoload_subscribers is true (default)' do
      let(:events_config) { double(autoload_subscribers: true, subscriber_registry: subscriber_registry) }

      before do
        stub_spree_preferences(events: events_config)
        create_subscriber_file('FooSubscriber')
      end

      it 'requires subscriber files and loads them into Spree::Event.subscribers' do
        expect do
          subscriber_registry.send(:require_subscriber_files)
        end.to change { subscriber_registry.to_h.count }.by 1

        expect(defined? Spree::FooSubscriber).to be_truthy
        expect(subscriber_registry.to_h).to include('Spree::FooSubscriber' => {})
      end
    end

    context 'when Spree::Config.autoload_subscribers is false' do
      let(:events_config) { double(autoload_subscribers: false, subscribers: subscriber_registry) }

      before do
        stub_spree_preferences(events: events_config)
        create_subscriber_file('BarSubscriber')
      end

      it 'does not requires subscriber files' do
        expect do
          subscriber_registry.send(:require_subscriber_files)
        end.not_to change { subscriber_registry.to_h.count }

        expect(defined? Spree::BarSubscriber).to be_falsey
        expect(subscriber_registry.to_h).to be_empty
      end
    end
  end
end
