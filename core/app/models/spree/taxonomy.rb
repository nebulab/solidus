# frozen_string_literal: true

module Spree
  class Taxonomy < Spree::Base
    acts_as_list

    validates :name, presence: true
    validates :name, uniqueness: true

    has_many :taxons, inverse_of: :taxonomy, dependent: false
    has_one :root, -> { where parent_id: nil }, class_name: "Spree::Taxon", dependent: :destroy, inverse_of: false

    after_save :set_name

    default_scope -> { order(position: :asc) }

    self.allowed_ransackable_attributes = %w[name]

    private

    def set_name
      if root
        root.update_columns(
          name:,
          updated_at: Time.current
        )
      else
        self.root = Spree::Taxon.create!(taxonomy_id: id, name:)
      end
    end
  end
end
