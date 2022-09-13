# frozen_string_literal: true

require 'spree/service_registry'

module Spree
  module Core
    module ControllerHelpers
      module ServiceRegistry
        def services
          Spree::ServiceRegistry
        end
      end
    end
  end
end
