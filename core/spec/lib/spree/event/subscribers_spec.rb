# frozen_string_literal: true

require 'spec_helper'
require 'spree/event'

RSpec.describe Spree::Event::Subscribers do
  module M
    include Spree::Event::Subscriber

    event_action :event_name

    def event_name(event)
      # code that handles the event
    end
  end

  let(:subscribers) { described_class.new }
  let(:asn_subscription) { double }

  before { allow(Spree::Event).to receive(:subscribe).and_return(asn_subscription) }
  before { allow(Spree::Event).to receive(:unsubscribe).and_return(asn_subscription) }

  describe '#register' do
    subject { subscribers.register(M) }

    it 'adds the subscriber to the subscribers hash as an empty array' do
      expect { subject }.to change { subscribers['M'] }.from(nil).to({})
    end
  end

  describe '#subscribe_all' do
    subject { subscribers.subscribe_all }

    context 'When the subscriber was not registrered' do
      it 'does not add the subscriber to the subscribers hash' do
        expect { subject }.not_to change { subscribers['M'] }
      end
    end

    context 'when the subscriber was registered' do
      before { subscribers.register(M) }

      it 'adds the subscriber to the subscribers hash' do
        expect { subject }.to change { subscribers['M'] }.to({ event_name: asn_subscription })
      end
    end
  end

  describe '#unsubscribe_all' do
    subject { subscribers.unsubscribe_all }

    context 'when the subscriber was not registered' do
      it 'does not change the subscribers hash' do
        expect { subject }.not_to change { subscribers }
      end
    end

    context 'when the subscriber was registered' do
      before { subscribers.register(M) }

      context 'when the subscriber was not subscribed' do
        it 'does not change the subscribers hash' do
          expect { subject }.not_to change { subscribers }
        end
      end

      context 'when the subscriber was subscribed' do
        before { subscribers.subscribe_all }

        it 'removes the subscription from the subscribers hash' do
          expect { subject }.to change { subscribers['M'] }.to({})
        end
      end
    end
  end
end
