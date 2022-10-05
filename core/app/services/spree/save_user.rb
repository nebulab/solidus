# frozen_string_literal: true

require 'spree/transaction'

module Spree
  class SaveUser < Spree::Transaction
    operations :save_record,
               :update_user_roles,
               :update_user_stock_locations

    def call(user, attributes, ability:, role_ids:, stock_location_ids:)
      transaction do
        save_record(user, attributes)
        update_user_roles(user, role_ids, ability) if role_ids
        update_user_stock_locations(user, stock_location_ids, ability) if stock_location_ids
        user.reload
      end
    end
  end
end
