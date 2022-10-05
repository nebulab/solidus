# frozen_string_literal: true

module Spree
  class Result
    def self.success(value)
      Success.new(value)
    end

    def self.failure(error)
      Failure.new(error)
    end

    def to_result
      self
    end

    class Success < Result
      def initialize(value)
        @value = value
      end

      def value!
        @value
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
        block.call(value!)
      end
    end

    class Failure < Result
      def initialize(error)
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
