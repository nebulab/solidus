# frozen_string_literal: true

require 'rails_helper'
require Spree::Core::Engine.root.join('db/migrate/20191001071110_convert_calculator_type_to_promotion_calculators.rb')

RSpec.describe ConvertCalculatorTypeToPromotionCalculators, type: :migration,
                                                            described: 20191001071110,
                                                            previous: 20190220093635 do
  subject { |example| described_migration(example) }

  # This promotion factory creates a promotion action with
  # the flat rate calculator.
  let(:promotion) { create(:promotion, :with_order_adjustment) }
  let(:calculator) { promotion.actions.first.calculator }

  context 'when there are calculators with the old names' do
    before { calculator.update_column(:type, 'Spree::Calculator::FlatRate') }

    it 'converts old names to the new namespace' do
      subject
      expect(promotion.reload.actions.first.calculator.type).to eq 'Spree::Calculator::Promotion::FlatRate'
    end
  end
end
