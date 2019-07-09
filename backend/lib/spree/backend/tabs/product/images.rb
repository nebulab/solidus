# frozen_string_literal: true

require 'spree/backend/tabs/product/base'

module Spree
  module Backend
    module Tabs
      class Product
        class Images < Base
          def name
            'Images'
          end

          def presentation
            I18n.t('spree.images')
          end

          def url
            routes.admin_product_images_url(product)
          end

          def visible?
            ability.can?(:admin, Spree::Image) && !product.deleted?
          end
        end
      end
    end
  end
end
