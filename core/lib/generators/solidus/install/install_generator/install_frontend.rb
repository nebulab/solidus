# frozen_string_literal: true

module Solidus
  class InstallGenerator < Rails::Generators::AppBase
    class InstallFrontend
      attr_reader :bundler_context,
                  :generator_context

      def initialize(bundler_context:, generator_context:)
        @bundler_context = bundler_context
        @generator_context = generator_context
      end

      def call(frontend)
        case frontend
        when 'solidus_frontend'
          install_solidus_frontend
        when 'solidus_starter_frontend'
          install_solidus_starter_frontend
        else
          install_custom_frontend
        end
      end

      private

      def bundle_command(command)
        @generator_context.say_status :run, "bundle #{command}"
        bundle_path = Gem.bin_path("bundler", "bundle")

        BundlerContext.bundle_cleanly do
          system(
            Gem.ruby,
            bundle_path,
            *command.shellsplit,
          )
        end
      end

      def install_solidus_frontend
        unless @bundler_context.component_in_gemfile?(:frontend)
          bundle_command 'add solidus_frontend'
        end

        # Solidus bolt will be handled in the installer as a payment method.
        begin
          skip_solidus_bolt = ENV['SKIP_SOLIDUS_BOLT']
          ENV['SKIP_SOLIDUS_BOLT'] = 'true'
          @generator_context.generate("solidus_frontend:install #{@generator_context.options[:auto_accept] ? '--auto-accept' : ''}")
        ensure
          ENV['SKIP_SOLIDUS_BOLT'] = skip_solidus_bolt
        end
      end

      def install_solidus_starter_frontend
        remove_solidus_frontend
        @generator_context.apply "https://raw.githubusercontent.com/solidusio/solidus_starter_frontend/gsmendoza/sol-547-fix-ensure-that-ssf-32-doesnt-add/template.rb"
      end

      def install_custom_frontend
        remove_solidus_frontend
        @generator_context.apply ENV['FRONTEND'] or abort("Frontend installation failed.")
      end

      def remove_solidus_frontend
        return unless @bundler_context.component_in_gemfile?(:frontend)

        @bundler_context.remove(['solidus_frontend'])
      end
    end
  end
end
