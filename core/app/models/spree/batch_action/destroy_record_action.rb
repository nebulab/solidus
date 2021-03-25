# frozen_string_literal: true

module Spree
  module BatchAction
    class DestroyRecordAction < Base
      def call(collection)
        collection.map do |record|
          next if record.try(:discard)
          next if record.try(:destroy)

          record.id
        end
      end
    end
  end
end
