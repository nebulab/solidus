# frozen_string_literal: true

module Spree
  class OperationRegistry
    def initialize(overrides = {})
      @const_resolver = ->(key) { "Spree::Operations::#{key.to_s.camelize}".constantize }
      @defaults = Hash.new do |_hash, key|
        @const_resolver.call(key).new
      end
      @overrides = overrides
    end

    def [](key)
      @overrides[key] || @defaults[key]
    end

    def key?(key)
      @overrides[key] || defined?(@const_resolver.call(key))
    end

    def merge(**hash)
      @overrides.merge!(hash)
      self
    end
  end
end
