# frozen_string_literal: true

module Spree
  module PermissionSets
    # Read-only permissions for users, roles and store credits.
    #
    # This permission set allows users to view all related information about
    # users, roles and store credits, also from the admin panel.
    class UserDisplay < PermissionSets::Base
      def activate!
        can [:read, :admin, :edit, :addresses, :orders, :items], Spree.user_class
        can [:read, :admin], Spree::StoreCredit
        can [:read, :admin], Spree::Role
      end
    end
  end
end
