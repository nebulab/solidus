# frozen_string_literal: true

require 'dry/types'

module Spree
  # Types used in Solidus codebase
  #
  # This module includes all built-in types defined in
  # [dry-types](https://dry-rb.org/gems/dry-types/) library, plus allows us to
  # define and reuse our own types.
  module Types
    include Dry.Types()
  end
end
