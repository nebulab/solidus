# frozen_string_literal: true

module Spree
  class Role < Spree::Base
    has_many :role_users, class_name: "Spree::RoleUser", dependent: :destroy
    has_many :role_permissions, dependent: :destroy
    has_many :permission_sets, through: :role_permissions
    has_many :users, through: :role_users

    scope :non_base_roles, -> { where.not(name: ['admin']) }

    validates_uniqueness_of :name, case_sensitive: true
    validates :name, uniqueness: true
    after_save :assign_permissions

    def admin?
      name == "admin"
    end

    def permission_sets_constantized
      permission_sets.map(&:set).map(&:constantize)
    end

    def assign_permissions
      ::Spree::Config.roles.assign_permissions name, permission_sets_constantized
    end

    def can_be_deleted?
      permission_sets.find_by(set: ["Spree::PermissionSets::SuperUser", "Spree::PermissionSets::DefaultCustomer"]).nil?
    end
  end
end
