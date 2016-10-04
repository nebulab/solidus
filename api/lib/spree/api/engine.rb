require 'rails/engine'

module Spree
  module Api
    class Engine < Rails::Engine
      isolate_namespace Spree
      engine_name 'spree_api'

      Rabl.configure do |config|
        config.include_json_root = false
        config.include_child_root = false

        # Motivation here it make it call as_json when rendering timestamps
        # and therefore display miliseconds. Otherwise it would fall to
        # JSON.dump which doesn't display the miliseconds
        config.json_engine = ActiveSupport::JSON
      end

      initializer "spree.api.environment", before: :load_config_initializers do |_app|
        Spree::Api::Config = Spree::ApiConfiguration.new
      end

      initializer "spree.api.versioncake" do |_app|
        VersionCake.setup do |config|
          config.resources do |r|
            r.resource %r{.*}, [], [], [1]
          end
          config.missing_version = 1
          config.extraction_strategy = :http_header
        end
      end

      def self.root
        @root ||= Pathname.new(File.expand_path('../../../../', __FILE__))
      end
    end
  end
end