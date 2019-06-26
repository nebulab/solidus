# frozen_string_literal: true

module Spree
  module Core
    class StateMachines
      attr_writer :return_authorization

      def return_authorization
        require 'spree/core/state_machines/base_return_authorization'

        @return_authorization ||= 'Spree::Core::StateMachines::BaseReturnAuthorization'
        @return_authorization.constantize
      end
    end
  end
end
