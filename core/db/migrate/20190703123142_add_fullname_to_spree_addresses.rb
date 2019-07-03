class AddFullnameToSpreeAddresses < ActiveRecord::Migration[5.2]
  def change
    # TODO: do we need a database constraint to enforce validation here?
    add_column :spree_addresses, :fullname, :string
  end
end
