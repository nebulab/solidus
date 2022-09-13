# frozen_string_literal: true

module Spree
  module Operations
    class SaveRecord
      def call(record, attributes)
        record.assign_attributes(attributes)
        if record.save
          Spree::Result.success(record)
        else
          Spree::Result.failure(record.errors)
        end
      end
    end
  end
end
