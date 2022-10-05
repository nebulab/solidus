# frozen_string_literal: true

require "spree/registry"
require "spree/result_adapter"
require "kwork/transaction"
require "kwork/extensions/active_record"

module Spree
  class Transaction < Kwork::Transaction
    def self.operations(*operations)
      @operations = operations
    end

    def self.inherited(klass)
      klass.define_method(:initialize) do
        super(
          operations: Hash[
            self.class.instance_variable_get(:@operations).map do |name|
              [name, Spree::OperationRegistry[name]]
            end
          ],
          adapter: Spree::ResultAdapter,
          extension: Kwork::Extensions::ActiveRecord
        )
      end
    end
  end
end

Spree::Transaction.with_delegation
