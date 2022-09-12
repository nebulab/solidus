# frozen_string_literal: true

module Spree
  class Transaction
    def self.[](registry:)
      Class.new(Module) do
        attr_reader :registry

        def initialize(registry:)
          @registry = registry
        end

        def included(klass)
          klass.extend(ClassMethods)
          class_exec(registry) do |registry|
            klass.define_method(:initialize) do |**kwargs|
              @registry = registry.merge(kwargs)
            end
          end

          klass.define_method(:call) do |input|
            catch(:halt) do
              transaction = klass.instance_variable_get(:@block)
              final_result = Execution.new(registry: @registry).instance_exec(input, &transaction)
              Spree::Result.success(final_result)
            end
          end
        end
      end.new(registry: registry)
    end

    module ClassMethods
      def transaction(&block)
        @block = block
      end
    end

    class Execution
      attr_reader :registry

      def initialize(registry:)
        @registry = registry
      end

      def [](step, *args, **kwargs)
        result = registry[step].call(*args, **kwargs)
        if result.failure?
          throw :halt, result
        else
          result.result!
        end
      end

      def method_missing(step, *args, **kwargs)
        registry.key?(step) ? self[step, *args, **kwargs] : super
      end

      def respond_to_missing?(step, include_all)
        registry.key?(step) || super
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
