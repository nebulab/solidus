# frozen_string_literal: true

module Spree
  module DefaultPrice
    extend ActiveSupport::Concern

    def default_price(store)
      prices.with_discarded.currently_valid.with_default_attributes(store)&.first
    end

    def find_or_build_default_price(store)
      default_price(store) || prices.build(Spree::Config.default_pricing_options(store).desired_attributes)
    end
    delegate :price, :price=, to: :find_or_build_default_price

    def display_price(store)
      find_or_build_default_price(store).display_price
    end

    def display_amount(store)
      find_or_build_default_price(store).display_amount
    end

    def price(store)
      find_or_build_default_price(store).price
    end

    def price=(store, amount)
      find_or_build_default_price(store).price = amount
    end

    def has_default_price?(store)
      price = default_price(store)
      price.present? && !price.discarded?
    end

    def update_default_price_amount(store, amount)
      find_or_build_default_price(store).update!(amount: amount)
    end
  end
end
