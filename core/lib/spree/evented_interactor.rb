# frozen_string_literal: true

module Spree
  # This module adds the ability to write evented interactors, which are interactors
  # with automated events
  #
  # * if the interactor succeeds, the `on_success` event will be fired
  # * if the interactor fails, the `on_failure` event will be fired
  # * if the interactor errors, the `on_error` event will be fired
  #
  # @see Spree::Event#subscribe
  #
  # A few customizations can be achieved by overriding some private default methods
  # that are documented below.
  #
  # @example Basic interactor, with no customization
  #  class Spree::OrderFinalizer
  #    include EventedInteractor
  #
  #    def call
  #      context.order.update finalized: true
  #    end
  #  end
  #
  #  Spree::Event.subscribe 'spree/order_finalizer' do |event|
  #    order = event.payload[:subject].order
  #    Spree::Mailer.confirm_email(order).deliver_later
  #  end
  #
  #  Spree::Event.subscribe 'spree/order_finalizer_failure' do |event|
  #    order = event.payload[:subject].order
  #    AdminNotifier.order_not_finalized(order).deliver_later
  #  end
  #
  #  Spree::Event.subscribe 'spree/order_finalizer_error' do |event|
  #    order = event.payload[:subject].order
  #    AdminNotifier.order_interactor_error(order).deliver_later
  #  end
  #
  # @example Interactor with event customizations
  #  class Spree::OrderFinalizer
  #    include EventedInteractor
  #
  #    def call
  #      order.update finalized: true
  #    end
  #
  #    private
  #
  #    def order
  #      context.order
  #    end
  #
  #    def event_name
  #      'order_finalized'
  #    end
  #
  #    def event_subject
  #      order
  #    end
  #  end
  #
  #  Spree::Event.subscribe 'order_finalized' do |event|
  #    order = event.payload[:subject]
  #    Spree::Mailer.confirm_email(order).deliver_later
  #  end
  module EventedInteractor
    include Event::Organizable

    def self.included(base)
      base.send :include, Interactor
      base.send :prepend, InteractorWrapper
    end


    module InteractorWrapper
      # For internal use only. This method wraps the original Interactor#run!
      # in order to add on_failure, on_error and on_success event callbacks.
      def run!
        begin
          super
        rescue Interactor::Failure
          on_failure
          raise
        rescue
          on_error
          raise
        end
        on_success
      end
    end
  end
end
