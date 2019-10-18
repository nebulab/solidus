# frozen_string_literal: true

require_relative 'migrations/migrator_helper'

RSpec.configure do |config|
  config.include Migrations::MigratorHelpers, type: :migration

  # This is needed for MySQL since it is not able to rollback to the previous
  # state when database schema changes within that transaction.
  config.before(:all, type: :migration) { self.use_transactional_tests = false }
  config.after(:all, type: :migration)  { self.use_transactional_tests = true }

  config.around(:each, type: :migration) do |example|
    # Silence migrations output in specs report.
    ActiveRecord::Migration.suppress_messages do
      migrate_to_previous_migration_for(example)
      clear_tables_cache(example)

      example.run

      DatabaseCleaner.clean_with(:truncation)
      clear_tables_cache(example)
      migrate_to_last_migration
    end
  end
end
