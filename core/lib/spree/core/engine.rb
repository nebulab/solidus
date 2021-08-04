# frozen_string_literal: true

require 'spree/config'

module Spree
  module Core
    class Engine < ::Rails::Engine
      CREDIT_CARD_NUMBER_PARAM = /payment.*source.*\.number$/
      CREDIT_CARD_VERIFICATION_VALUE_PARAM = /payment.*source.*\.verification_value$/

      isolate_namespace Spree
      engine_name 'spree'

      config.generators do |generator|
        generator.test_framework :rspec
      end

      initializer "spree.environment", before: :load_config_initializers do |app|
        app.config.spree = Spree::Config.environment
      end

      # leave empty initializers for backwards-compatability. Other apps might still rely on these events
      initializer "spree.default_permissions", before: :load_config_initializers do; end
      initializer "spree.register.calculators", before: :load_config_initializers do; end
      initializer "spree.register.stock_splitters", before: :load_config_initializers do; end
      initializer "spree.register.payment_methods", before: :load_config_initializers do; end
      initializer 'spree.promo.environment', before: :load_config_initializers do; end
      initializer 'spree.promo.register.promotion.calculators', before: :load_config_initializers do; end
      initializer 'spree.promo.register.promotion.rules', before: :load_config_initializers do; end
      initializer 'spree.promo.register.promotions.actions', before: :load_config_initializers do; end
      initializer 'spree.promo.register.promotions.shipping_actions', before: :load_config_initializers do; end

      # Filter sensitive information during logging
      initializer "spree.params.filter", before: :load_config_initializers do |app|
        app.config.filter_parameters += [
          %r{^password$},
          %r{^password_confirmation$},
          CREDIT_CARD_NUMBER_PARAM,
          CREDIT_CARD_VERIFICATION_VALUE_PARAM,
        ]
      end

      initializer "spree.core.checking_migrations", before: :load_config_initializers do |_app|
        Migrations.new(config, engine_name).check
      end

      # Register core events
      initializer 'spree.core.register_events' do
        %w[
          order_finalized
          order_recalculated
          reimbursement_reimbursed
          reimbursement_errored
        ].each { |event_name| Spree::Event.register(event_name) }
      end

      # Setup Event Subscribers
      initializer 'spree.core.initialize_subscribers' do |app|
        app.reloader.to_prepare do
          Spree::Event.activate_autoloadable_subscribers
        end

        app.reloader.before_class_unload do
          Spree::Event.deactivate_all_subscribers
        end
      end

      # Load in mailer previews for apps to use in development.
      initializer "spree.core.action_mailer.set_preview_path", after: "action_mailer.set_configs" do |app|
        original_preview_path = app.config.action_mailer.preview_path
        solidus_preview_path = Spree::Core::Engine.root.join 'lib/spree/mailer_previews'

        app.config.action_mailer.preview_path = "{#{original_preview_path},#{solidus_preview_path}}"
        ActionMailer::Base.preview_path = app.config.action_mailer.preview_path
      end
    end
  end
end
