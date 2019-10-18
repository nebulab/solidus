# frozen_string_literal: true

module Migrations
  module MigratorHelpers
    def migrate_to_described_migration_for(example)
      migrate(example.metadata[:described])
    end
    alias :described_migration :migrate_to_described_migration_for

    def migrate_to_previous_migration_for(example)
      migrate(example.metadata[:previous], :down)
    end

    def migrate(version = nil, direction = :up)
      if Rails.gem_version >= Gem::Version.new('6.0.0')
        ActiveRecord::Migrator.new(direction, migrations, ActiveRecord::SchemaMigration, version).migrate
      else
        ActiveRecord::Migrator.new(direction, migrations, version).migrate
      end
    end

    def migrate_to_last_migration
      migrate
    end

    def migrations_paths
      ActiveRecord::Migrator.migrations_paths
    end

    def migrations
      if Rails.gem_version >= Gem::Version.new('6.0.0')
        ActiveRecord::MigrationContext.new(
          migrations_paths,
          ActiveRecord::SchemaMigration
        ).migrations
      elsif Rails.gem_version >= Gem::Version.new('5.2.0')
        ActiveRecord::MigrationContext.new(migrations_paths).migrations
      else
        ActiveRecord::Migrator.migrations(migrations_paths)
      end
    end

    def clear_tables_cache(example)
      (example.metadata[:reset_tables] || []).each(&:reset_column_information)
    end
  end
end
