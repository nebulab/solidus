# frozen_string_literal: true

class AddNameToSpreeAddresses < ActiveRecord::Migration[5.2]
  class AddressForMigration < ApplicationRecord
    self.table_name = 'spree_addresses'
  end

  def up
    if AddressForMigration.where.not(firstname: [nil, '']).exists?
      AddNameToSpreeAddresses.raise_error
    end

    add_column :spree_addresses, :name, :string
    add_index :spree_addresses, :name
  end

  def down
    remove_index :spree_addresses, :name
    remove_column :spree_addresses, :name
  end

  def self.raise_error
    raise <<~MESSAGE
      ACTION REQUIRED: This migration will add `name` column to
      `spree_addresses` table.
      You should make sure to verify that new any custom code will not
      conflict with the new `Spree::Address#name` attribute and to migrate
      the any content present in `firstname` and `lastname` columns to `name`
      column.
      If you are ready to proceed with the migration you can edit
      `20210122110141_add_name_to_spree` file and remove this check.
    MESSAGE
  end
end
