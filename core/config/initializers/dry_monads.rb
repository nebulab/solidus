# frozen_string_literal: true

require 'dry/core/extensions'
require 'dry/monads'

# This initializer defines an extension for Dry::Monads to transform result
# related dry-monads's objects into a Spree::Result

module Dry
  module Monads
    extend Dry::Core::Extensions

    register_extension(:spree_result) do
      class Result
        class Success < Result
          # @return [Spree::Result]
          def to_spree_result
            Spree::Result.new(result: value!)
          end
        end

        class Failure < Result
          # @return [Spree::Result]
          def to_spree_result
            Spree::Result.new(failure: failure)
          end
        end
      end

      class Maybe
        # @return [Spree::Result]
        def to_spree_result
          to_result
            .to_spree_result
        end
      end

      class Try
        # @return [Spree::Result]
        def to_spree_result
          to_result
            .to_spree_result
        end
      end
    end
  end
end

Dry::Monads.load_extensions(:spree_result)
