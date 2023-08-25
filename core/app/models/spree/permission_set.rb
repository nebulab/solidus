# frozen_string_literal: true

module Spree
  class PermissionSet < Spree::Base
    has_many :role_permissions
    has_many :roles, through: :role_permissions

    validates :name, :set, presence: true

    scope :display_permissions, -> { where('name LIKE ?', '%Display') }
    scope :management_permissions, -> { where('name LIKE ?', '%Management') }

    scope :custom_permissions, -> {
      where.not(id: display_permissions)
      .where.not(id: management_permissions)
      .where.not(set: ['Spree::PermissionSets::SuperUser', 'Spree::PermissionSets::DefaultCustomer'])
    }
  end
end
