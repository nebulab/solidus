# frozen_string_literal: true

module Spree
  module Admin
    module ActionableHelper
      extend ActiveSupport::Concern

      def batch_action_buttons(batch_actions)
        batch_actions.map do |batch_action|
          link_to_batch_action(batch_action)
        end
      end

      def link_to_batch_action(icon:, label:, action:)
        options = {}
        options[:class] = "fa fa-#{icon} icon_link with-tip batch-action no-text"
        options[:title] = label
        options[:data] = { action: action }
        options.delete(:no_text)
        link_to('', '#', options)
      end
    end
  end
end
