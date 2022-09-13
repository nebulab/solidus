# frozen_string_literal: true

module Spree
  module Operations
    class UpdateUserRoles
      # Updates the roles in keeping with the given ability's permissions
      #
      # Roles that are not accessible to the given ability will be ignored. It
      # also ensure not to remove non accessible roles when assigning new
      # accessible ones.
      #
      # @param given_roles [Spree::Role]
      # @param ability [Spree::Ability]
      def call(user, given_role_ids, ability)
        given_roles = Spree::Role.where(id: given_role_ids)
        accessible_roles = Spree::Role.accessible_by(ability)
        non_accessible_roles = Spree::Role.all - accessible_roles
        new_accessible_roles = given_roles - non_accessible_roles
        user.spree_roles = user.spree_roles - accessible_roles + new_accessible_roles
        Spree::Result.success(user.spree_roles)
      end
    end
  end
end
