# frozen_string_literal: true

require 'spec_helper'

describe Spree::Backend::Batch do
  let(:described_module) { Spree::Backend::Batch }
  let(:controller_class) do
    class FakesController < ApplicationController
      include Spree::Backend::Batch
      set_batch_actions []
    end
  end

  before do
    controller_class
  end

  describe '.set_batch_actions' do
    before do
      FakesController.class_eval do
        set_batch_actions [{ action: 'Spree::Action' }]
      end
    end

    it 'has set batch actions' do
      expect(FakesController.batch_actions).to eq [{ action: 'Spree::Action' }]
    end
  end

  describe '.add_batch_actions' do
    before do
      FakesController.class_eval do
        add_batch_actions [{ action: 'Spree::Action' }]
      end
    end

    it 'has set batch actions' do
      expect(FakesController.batch_actions).to eq [{ action: 'Spree::Action' }]
    end
  end

  describe '.add_batch_action' do
    before do
      FakesController.class_eval do
        add_batch_action({ action: 'Spree::Action' })
      end
    end

    it 'has set batch actions' do
      expect(FakesController.batch_actions).to eq [{ action: 'Spree::Action' }]
    end
  end
end
