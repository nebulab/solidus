# frozen_string_literal: true

module Spree
  module Backend
    module Batch
      extend ActiveSupport::Concern

      included do
        helper_method :batch_actions
        helper 'spree/admin/actionable'
      end

      module ClassMethods
        attr_writer :batch_actions

        def batch_actions
          @batch_actions || []
        end

        protected

        def set_batch_actions(args)
          @batch_actions = args
        end

        def add_batch_action(batch_action)
          @batch_actions = batch_actions << batch_action
        end

        def add_batch_actions(other_batch_actions)
          @batch_actions = batch_actions + other_batch_actions
        end
      end

      protected

      def batch_actions
        self.class.batch_actions
      end
    end
  end
end
