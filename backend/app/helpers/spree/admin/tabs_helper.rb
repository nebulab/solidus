# frozen_string_literal: true

module Spree
  module Admin
    module TabsHelper
      def product_tabs(active_tab_name:, product:)
        Spree::Backend::Tabs::Product.new(
          object: product,
          active_tab_name: active_tab_name,
          routes: spree,
          user: spree_current_user
        )
      end
    end
  end
end
