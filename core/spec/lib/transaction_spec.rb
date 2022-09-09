# frozen_string_literal: true

require 'spree/transaction'

describe Spree::Transaction do
  it 'chains steps' do
    one = ->(x) { Spree::Result.success(x + 1) }
    two = ->(x) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry]

      transaction do |input, t|
        result_one = t[:one, input]
        t[:two, result_one]
      end
    end.new

    expect(instance.call(1).result!).to be(4)
  end

  it 'hails on failure' do
    one = ->(x) { Spree::Result.success(x + 1) }
    two = ->(x) { Spree::Result.failure(:stop) }
    three = ->(x) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    registry[:three] = three
    instance = Class.new do
      include Spree::Transaction[registry: registry]

      transaction do |input, t|
        result_one = t[:one, input]
        result_two = t[:two, input]
        t[:three, result_two]
      end
    end.new

    expect(instance.call(1).failure!).to be(:stop)
  end
end
