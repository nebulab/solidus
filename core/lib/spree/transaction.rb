# frozen_string_literal: true

require "spree/registry"

module Spree
  module Transaction
    def self.included(klass)
      klass.include(self[])
    end

    def self.[](registry: Spree::OperationRegistry, db: true)
      Class.new(Module) do
        def initialize(registry:, db:)
          @registry = registry
          @db = db
        end

        def included(klass)
          klass.extend(ClassMethods)
          class_exec(@registry, @db) do |registry, db|
            klass.define_method(:initialize) do |**kwargs|
              @registry = registry.merge(**kwargs)
              @db = db
            end
          end

          klass.define_method(:call) do |*args, **kwargs|
            result = nil

            (@db ? ActiveRecord::Base.method(:transaction) : method(:yield_self)).call do
              catch(:halt) do
                transaction = klass.instance_variable_get(:@block)
                unwrapped_result = Execution.new(registry: @registry).instance_exec(*args, **kwargs, &transaction)
                Spree::Result.success(unwrapped_result)
              end.tap do |wrapped_result|
                result = wrapped_result
                raise ActiveRecord::Rollback if result.failure? && @db
              end
            end

            result
          end
        end
      end.new(registry: registry, db: db)
    end

    module ClassMethods
      def transaction(db: true, &block)
        @block = block
        @db = db
      end
    end

    class Execution
      def initialize(registry:)
        @registry = registry
        @raw = false
      end

      def [](name, *args, **kwargs)
        result = @registry[name].call(*args, **kwargs)
        return result if @raw

        result = result.to_result
        if result.failure?
          throw :halt, result
        else
          result.result!
        end
      end

      def raw
        @raw = true
        yield
      ensure
        @raw = false
      end

      def method_missing(name, *args, **kwargs)
        @registry.key?(name) ? self[name, *args, **kwargs] : super
      end

      def respond_to_missing?(name, include_all)
        @registry.key?(name) || super
      end
    end
  end

  class Result
    def self.success(result)
      Success.new(result: result)
    end

    def self.failure(error)
      Failure.new(error: error)
    end

    def to_result
      self
    end

    class Success < Result
      def initialize(result: nil)
        @result = result
      end

      def result!
        @result
      end

      def error!
        raise
      end

      def success?
        true
      end

      def failure?
        false
      end

      def bind(&block)
        block.call(result!)
      end
    end

    class Failure < Result
      def initialize(error: nil)
        @error = error
      end

      def result!
        raise
      end

      def error!
        @error
      end

      def success?
        false
      end

      def failure?
        true
      end

      def bind(&block)
        self
      end
    end
  end
end
