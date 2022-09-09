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

  it 'stops chain on failure' do
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

    expect(instance.call(1).error!).to be(:stop)
  end

  it 'can work on intermediate results' do
    one = ->(x) { Spree::Result.success(x + 1) }
    two = ->(x) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry]

      transaction do |input, t|
        result_one = t[:one, input]
        t[:two, result_one + 1]
      end
    end.new

    expect(instance.call(1).result!).to be(5)
  end

  it 'stops execution on failure' do
    one = ->(x) { Spree::Result.failure(:stop) }
    registry = {}
    registry[:one] = one
    instance = Class.new do
      include Spree::Transaction[registry: registry]

      transaction do |input, t|
        t[:one, input]
        raise "It doesn't pop up"
      end
    end.new

    expect { instance.call(1).error! }.not_to raise_error
  end

  it 'steps can be anything responding to call' do
    one = Class.new do
      def call(input)
        Spree::Result.success(input + 1)
      end
    end.new
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

  it 'steps can be injected on initialization' do
    default_one = ->(x) { Spree::Result.success(x + 1) }
    injected_one = ->(x) { Spree::Result.success(x + 2) }
    two = ->(x) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = default_one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry]

      transaction do |input, t|
        result_one = t[:one, input]
        t[:two, result_one]
      end
    end.new(one: injected_one)

    expect(instance.call(1).result!).to be(5)
  end
end
