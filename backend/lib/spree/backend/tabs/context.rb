# frozen_string_literal: true

module Spree
  module Backend
    module Tabs
      class Context
        attr_reader :object, :active_tab_name, :routes, :user

        def initialize(object:, active_tab_name:, routes:, user:)
          @object = object
          @active_tab_name = active_tab_name
          @routes = routes
          @user = user
        end

        def ability
          Spree::Ability.new(user)
        end

        def plural_resource_name(resource_class)
          resource_class.model_name.human(count: Spree::I18N_GENERIC_PLURAL)
        end
      end
    end
  end
end
