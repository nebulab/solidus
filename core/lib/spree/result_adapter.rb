# frozen_string_literal: true

require "spree/result"

module Spree
  class ResultAdapter
    def self.wrap(value)
      Spree::Result.success(value)
    end

    def self.unwrap(result)
      result.value!
    end

    def self.success?(result)
      result.success?
    end
  end
end
