# frozen_string_literal: true

module Spree
  module PermissionSets
    # Permissions for viewing and editing the user roles.
    #
    # This permission set allows full control over roles, but only allows reading users.
    class RoleManagement < PermissionSets::Base
      def activate!
        can [:read, :admin, :edit, :addresses, :orders, :items], Spree.user_class
        can :manage, Spree::Role
      end
    end
  end
end
