# frozen_string_literal: true

module Spree
  ServiceRegistry = Hash.new do |_hash, key|
    "Spree::#{key.to_s.camelize}".constantize.new
  end
end
