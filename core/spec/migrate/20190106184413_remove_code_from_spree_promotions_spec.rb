# frozen_string_literal: true

require 'rails_helper'
require Spree::Core::Engine.root.join('db/migrate/20190106184413_remove_code_from_spree_promotions.rb')

RSpec.describe RemoveCodeFromSpreePromotions, type: :migration,
                                              described: 20190106184413,
                                              previous: 20180710170104,
                                              reset_tables: [Spree::Promotion] do
  subject { |example| described_migration(example) }
  let(:promotion_with_code) { create(:promotion) }
  before do
    # We can't set code via factory since `code=` is currently raising
    # an error, see more at:
    # https://github.com/solidusio/solidus/blob/cf96b03eb9e80002b69736e082fd485c870ab5d9/core/app/models/spree/promotion.rb#L65
    promotion_with_code.update_column(:code, code)
  end

  context 'when there are no promotions with code' do
    let(:code) { '' }

    it 'does not call any promotion with code handler' do
      expect(described_class).not_to receive(:promotions_with_code_handler)

      subject
    end
  end

  context 'when there are promotions with code' do
    let(:code) { 'Just An Old Promo Code' }

    context 'with the deafult handler (Solidus::Migrations::PromotionWithCodeHandlers::RaiseException)' do
      it 'raise a StandardError exception' do
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'changing the default handler' do
      before do
        allow(described_class)
          .to receive(:promotions_with_code_handler)
          .and_return(promotions_with_code_handler)
      end

      context 'to Solidus::Migrations::PromotionWithCodeHandlers::MoveToSpreePromotionCode' do
        let(:promotions_with_code_handler) { Solidus::Migrations::PromotionWithCodeHandlers::MoveToSpreePromotionCode }

        context 'when there are no Spree::PromotionCode with the same value' do
          it 'moves the code into a Spree::PromotionCode' do
            migration_context = double('a migration context')
            allow_any_instance_of(promotions_with_code_handler)
              .to receive(:migration_context)
              .and_return(migration_context)

            expect(migration_context)
              .to receive(:say)
              .with("Creating Spree::PromotionCode with value 'just an old promo code' for Spree::Promotion with id '#{promotion_with_code.id}'")

            expect { subject }
              .to change { Spree::PromotionCode.all.size }
              .from(0)
              .to(1)
          end
        end

        context 'with promotions with type set (legacy feature)' do
          let(:promotion_with_code) { create(:promotion, type: 'Spree::Promotion') }

          it 'does not raise a STI error' do
            expect { subject }.not_to raise_error
          end
        end

        context 'when there is a Spree::PromotionCode with the same value' do
          context 'associated with the same promotion' do
            let!(:existing_promotion_code) { create(:promotion_code, value: 'just an old promo code', promotion: promotion_with_code) }

            it 'does not create a new Spree::PromotionCode' do
              expect { subject }.not_to change { Spree::PromotionCode.all.size }
            end
          end

          context 'associated with another promotion' do
            let!(:existing_promotion_code) { create(:promotion_code, value: 'just an old promo code') }

            it 'raises an exception' do
              expect { subject }.to raise_error(StandardError)
            end
          end
        end
      end

      context 'to Solidus::Migrations::PromotionWithCodeHandlers::DoNothing' do
        let(:promotions_with_code_handler) { Solidus::Migrations::PromotionWithCodeHandlers::DoNothing }

        it 'just prints a message' do
          migration_context = double('a migration context')
          allow_any_instance_of(promotions_with_code_handler)
            .to receive(:migration_context)
            .and_return(migration_context)

          expect(migration_context)
            .to receive(:say)
            .with("Code 'Just An Old Promo Code' is going to be removed from Spree::Promotion with id '#{promotion_with_code.id}'")

          subject
        end
      end
    end
  end
end
