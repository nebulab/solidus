# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::BatchAction::Base, type: :model do
  subject(:call) { Spree::BatchAction::Base.new.call }

  it 'raises an error when call is not overridden' do
    expect { call }.to raise_error(NotImplementedError)
  end
end
