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
              catch(:halt) do
                transaction = klass.instance_variable_get(:@block)
                final_result = transaction.call(input, Execution.new(registry: registry))
                Spree::Result.success(final_result)
              end
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
        result = Result.success(input).bind(&registry[step])
        if result.failure?
          throw :halt, result
        else
          result.result!
        end
      end
    end
  end

  class Result
    def self.success(result)
      new(result: result)
    end

    def self.failure(error)
      new(error: error)
    end

    def initialize(result: nil, error: nil)
      @result = result
      @error = error
    end

    def result!
      @result || raise
    end

    def failure!
      @error || raise
    end

    def success?
      !@result.nil?
    end

    def failure?
      !@error.nil?
    end

    def bind(&block)
      failure? ? self : block.call(result!)
    end
  end
end
