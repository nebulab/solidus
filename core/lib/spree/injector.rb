# frozen_string_literal: true

module Spree
  # Utility to inject {Spree::Container} dependencies.
  #
  # @example
  #   # Say that there's a `Spree::FooService` registered under `:foo_service`
  #   # key in {Spree::Container}.
  #   #
  #   # You can make it available to a controller calling {Injector.[]} method.
  #   class MyController < Spree::StoreController
  #     include Injector[:foo_service]
  #
  #     def action
  #       foo_service.call
  #       head :ok
  #     end
  #   end
  #
  # @see Spree::Container
  Injector = Spree::Container.injector
end
