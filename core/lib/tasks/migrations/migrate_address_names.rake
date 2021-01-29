# frozen_string_literal: true

class Spree::AddressForMigration < ActiveRecord::Base
  self.table_name = 'spree_addresses'
end

namespace 'solidus:migrations:migrate_address_names' do
  desc 'Backfills Spree::Address name attribute using firstname and lastname
    concatenation to keep historical data when upgrading to new address name
    format'
  # TODO show number or rows to update and ask for confirmation
  task up: :environment do
    puts "Updating #{Spree::Address.count} addresses"

    sqlite = ActiveRecord::Base.connection.adapter_name.downcase.starts_with?('sqlite')
    # TODO trim after concat
    statement = if sqlite
                  "name=(firstname || ' ' || lastname)"
                else
                  # TODO CONCAT_WS? (mysql?)
                  "name=CONCAT(firstname, ' ', lastname)"
                end
    # TODO test where
    Spree::AddressForMigration.unscoped.where.not(name: [nil, ''])).in_batches do |addresses|
      addresses.update_all(statement)
    end

    if !ActiveRecord::Base.connection.index_exists?(:spree_addresses, :name)
      ActiveRecord::Base.connection.add_index(:spree_addresses, :name)
    end

    puts 'Addresses updated'
  end
end
