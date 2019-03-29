# frozen_string_literal: true

module Spree
  module DeprecatedPaperclipAPI
    def self.prepended(base)
      unless ActiveStorage::Attached.public_methods.include?(:url)
        ActiveStorage::Attached.define_method :url do |*args|
          Spree::Deprecation.warn(
            "Using #{self.class}#url is deprecated, please use `#{record.class}#url` instead."
          )
          record&.url(*args)
        end
      end
    end

    def attachment(*args)
      if args.size == 1
        Spree::Deprecation.warn(
          "Using #{self.class}#attachment(<format>) is deprecated, please use `#{self.class}#url` instead."
        )
        style = args.first
        Spree::ActiveStorageAttachment.attachment_variant(
          super(),
          style: style,
          default_style: default_style,
          styles: self.class::ATTACHMENT_STYLES
        )&.service_url
      else
        # With 0 args will be ok, otherwise will raise an ArgumentError
        super
      end
    end

    def attachment?
      Spree::Deprecation.warn(
        "Using #{self.class}#attachment? is deprecated, please use "\
        "`#{self.class}#attachment_present?` instead."
      )
      attachment.attached?
    end
  end
end
