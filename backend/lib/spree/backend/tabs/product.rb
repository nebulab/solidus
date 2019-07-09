# frozen_string_literal: true

require 'spree/backend/tabs/context'

module Spree
  module Backend
    module Tabs
      class Product
        attr_reader :object, :active_tab_name, :routes, :user, :items

        def initialize(object:, active_tab_name:, routes:, user:)
          @object = object
          @active_tab_name = active_tab_name
          @routes = routes
          @user = user
          @items = Config.product_tabs
        end

        def each
          items.each do |item|
            yield item.new(
              tabs_context: context
            )
          end
        end

        private

        def context
          Spree::Backend::Tabs::Context.new(
            object: object,
            active_tab_name: active_tab_name,
            routes: routes,
            user: user
          )
        end
      end
    end
  end
end

require 'spree/backend/tabs/product/images'
require 'spree/backend/tabs/product/prices'
require 'spree/backend/tabs/product/product_details'
require 'spree/backend/tabs/product/product_properties'
require 'spree/backend/tabs/product/stock_management'
require 'spree/backend/tabs/product/variants'
