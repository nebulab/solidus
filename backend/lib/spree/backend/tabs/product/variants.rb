# frozen_string_literal: true

require 'spree/backend/tabs/product/base'

module Spree
  module Backend
    module Tabs
      class Product
        class Variants < Base
          def name
            'Variants'
          end

          def presentation
            plural_resource_name(Spree::Variant)
          end

          def url
            routes.admin_product_variants_url(product)
          end

          def visible?
            ability.can?(:admin, Spree::Variant)
          end
        end
      end
    end
  end
end
