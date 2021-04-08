# frozen_string_literal: true

require 'dry/struct'
require 'spree/types'

module Spree
  # Simple struct that represents the value returned by a service
  class Result < Dry::Struct
    schema schema.strict

    attribute? :result, Types::Any.optional
    attribute? :failure, Types::Any.optional

    # @return [Boolean]
    def success?
      failure.nil?
    end

    # @return [Boolean]
    def failure?
      result.nil?
    end
  end
end
