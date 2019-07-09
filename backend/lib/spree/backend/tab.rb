# frozen_string_literal: true

module Spree
  module Backend
    class Tab
      attr_reader :presentation, :url, :condition, :active

      def initialize(
        presentation:,
        url:,
        condition:,
        active:
      )

        @presentation = presentation
        @url = url
        @condition = condition
        @active = active
      end
    end
  end
end
