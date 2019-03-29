# frozen_string_literal: true

module Spree
  module DeprecatedPaperclipAPI
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
  end
end
