# frozen_string_literal: true

require 'spec_helper'
require 'spree/core'

RSpec.describe Spree::EventedInteractor do
  context 'when creating an interactor class that includes the module' do
    class C
      include Spree::EventedInteractor

      def call
        do_something
      end

      def event_name
        'c_interaction'
      end

      def event_subject
        self.class.name
      end

      private

      def do_something
      end
    end

    let(:item) { spy('object') }
    let(:notifier) { ActiveSupport::Notifications.notifier }

    before do
      # ActiveSupport::Notifications expose no interface to clean all
      # subscribers at once, so some low level brittle code is required
      @old_subscribers = notifier.instance_variable_get('@subscribers').dup
      @old_listeners = notifier.instance_variable_get('@listeners_for').dup
      notifier.instance_variable_get('@subscribers').clear
      notifier.instance_variable_get('@listeners_for').clear

      Spree::Event.subscribe('c_interaction_success') { item.success }
      Spree::Event.subscribe('c_interaction_error') { item.error }
      Spree::Event.subscribe('c_interaction_failure') { item.failure }
    end

    after do
      notifier.instance_variable_set '@subscribers', @old_subscribers
      notifier.instance_variable_set '@listeners_for', @old_listeners
    end

    context 'when the interactor succeeds' do
      it 'automatically triggers success events' do
        C.call
        expect(item).to have_received(:success)
      end
    end

    context 'when the interactor errors' do
      before do
        allow_any_instance_of(C).to receive(:do_something) { raise }
      end

      it 'automatically triggers error events and then raises the error' do
        expect { C.call }.to raise_error
        expect(item).to have_received(:error)
      end
    end

    context 'when the interactor fails' do
      before do
        allow_any_instance_of(C).to receive(:do_something) { |c| c.context.fail! }
      end

      it 'automatically triggers failure events' do
        C.call
        expect(item).to have_received(:failure)
      end
    end
  end
end
