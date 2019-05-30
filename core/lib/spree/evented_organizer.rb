# frozen_string_literal: true

module Spree
  module EventedOrganizer
    include Event::Organizable

    def self.included(base)
      base.send :include, Interactor::Organizer
      base.send :prepend, InteractorWrapper
    end

    module InteractorWrapper
      # For internal use only. This method wraps the original Interactor#run!
      # in order to add on_failure, on_error and on_success event callbacks.
      def call
        begin
          super
        rescue Interactor::Failure
          on_failure
          raise
        rescue
          on_error
          raise
        end
        on_success
      end
    end
  end
end
