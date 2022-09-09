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
            klass.define_method(:call) do |input|
              transaction = klass.instance_variable_get(:@block)
              Spree::Result.success(
                transaction.call(input, Execution.new(registry: registry))
              )
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

      def [](step, input)
        registry[step].call(input).result!
      end
    end
  end

  class Result
    def self.success(result)
      new(result: result)
    end

    def initialize(result:)
      @result = result
    end

    def result!
      @result || raise
    end
  end
end
