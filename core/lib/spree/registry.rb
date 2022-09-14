# frozen_string_literal: true

module Spree
  class Registry
    def initialize(namespace, overrides = {})
      @const_resolver = ->(key) { "#{namespace}::#{key.to_s.camelize}".constantize }
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

  ServiceRegistry = Registry.new('Spree', {})
  OperationRegistry = Registry.new('Spree::Operations', {})
end
