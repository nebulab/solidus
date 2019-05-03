module Spree
  module Presenter
    class Base < SimpleDelegator
      attr_reader :presentee

      def initialize(presentee)
        @presentee = presentee

        super(presentee)
      end
    end
  end
end
