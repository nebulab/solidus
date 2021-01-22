# frozen_string_literal: true

module Spree
  module Backend
    module Batch
      extend ActiveSupport::Concern

      included do
        helper_method :batch_actions
        before_action :batch_action_collection, only: [:preview_batch]
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

      def collection_actions
        super + [:preview_batch]
      end

      def batch_action_collection
        @batch_action_collection = @collection
      end

      def preview_batch
        session[:return_to] = request.url

        @batch_action_type = params[:batch_action_type]
        @batch_action_name = @batch_action_type.constantize.new.class.name.demodulize.underscore

        respond_to do |format|
          format.js do
            render inline: "$('#batch-preview .modal-body').html('<%= escape_javascript( render(partial: \"spree/admin/batch_actions/#{@batch_action_name}/preview\") ) %>')"
          end
        end
      end

      protected

      def batch_actions
        self.class.batch_actions
      end
    end
  end
end
