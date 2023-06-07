# frozen_string_literal: true

class CreateSpreePermissionSets < ActiveRecord::Migration[7.0]
  def change
    create_table :spree_permission_sets do |t|
      t.string :name
      t.string :set
      t.timestamps
    end
  end
end
