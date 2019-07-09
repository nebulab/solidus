# frozen_string_literal: true

module Spree
  module Backend
    module Tabs
      class Product
        class Base
          attr_reader :tabs_context
          delegate :object, :active_tab_name, :routes, :ability, :plural_resource_name, to: :tabs_context

          def initialize(tabs_context:)
            @tabs_context = tabs_context
          end

          def name
            raise NotImplementedError
          end

          def presentation
            raise NotImplementedError
          end

          def url
            raise NotImplementedError
          end

          def visible?
            raise NotImplementedError
          end

          def active?
            name == active_tab_name
          end

          def css_classes
            return 'active' if active?

            ''
          end

          private

          def product
            object
          end
        end
      end
    end
  end
end
