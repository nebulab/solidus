# frozen_string_literal: true

require 'spree/backend/tabs/product/base'

module Spree
  module Backend
    module Tabs
      class Product
        class ProductDetails < Base
          def name
            'Product Details'
          end

          def presentation
            I18n.t('spree.product_details')
          end

          def url
            routes.edit_admin_product_url(product)
          end

          def visible?
            ability.can?(:admin, Spree::Product)
          end
        end
      end
    end
  end
end
