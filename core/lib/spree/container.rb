# frozen_string_literal: true

require 'dry/system/container'

module Spree
  # Dependency injection container for Solidus internal dependencies.
  #
  # This class declaration registers default Solidus collaborator objects. They
  # are auto-registered following simple hierarchy and naming conventions (see
  # [dry-system](https://dry-rb.org/gems/dry-system/) for details).
  #
  # Users can switch a dependency through
  # {Spree::AppConfiguration#dependencies}, which yields this container.
  #
  # @example
  #   # Say there's a service in `core/app/services/spree/foo_service.rb` within
  #   # this repository, which must define a `Spree::FooService` class.
  #   #
  #   # An instance of the service will be made automatically available under:
  #   Container[:foo_service]
  #
  #   # However, an application using Spree can switch it in its Spree
  #   initializer:
  #   #
  #   # -- config/initializers/spree.rb
  #   Spree.config do |config|
  #     config.dependencies do |dependencies|
  #       dependencies.register(:foo_service, MyOwnFooService.new)
  #     end
  #   end
  #
  # @see Spree::Injector
  class Container < Dry::System::Container
    configure do
      config.name = :core
      config.root = File.join(Core::Engine.root, 'app')
      config.auto_register = %w[services]
      config.default_namespace = 'spree'
    end

    load_paths!('services')
  end
end
