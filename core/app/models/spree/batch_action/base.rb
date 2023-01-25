# frozen_string_literal: true

module Spree
  module BatchAction
    class Base
      def call(*_args)
        raise NotImplementedError, "Please implement '#call' in your action: #{self.class.name}"
      end
    end
  end
end
