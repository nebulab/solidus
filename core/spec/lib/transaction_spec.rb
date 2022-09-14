# frozen_string_literal: true

require 'spree/transaction'
require 'rails_helper'

RSpec.describe Spree::Transaction do
  it 'chains steps' do
    one = ->(x) { Spree::Result.success(x + 1) }
    two = ->(x) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do |input|
        result_one = one(input)
        two(result_one)
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
      include Spree::Transaction[registry: registry, db: false]

      transaction do |input|
        result_one = one(input)
        result_two = two(input)
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
      include Spree::Transaction[registry: registry, db: false]

      transaction do |input|
        result_one = one(input)
        two(result_one + 1)
      end
    end.new

    expect(instance.call(1).result!).to be(5)
  end

  it 'stops execution on failure' do
    one = ->(x) { Spree::Result.failure(:stop) }
    registry = {}
    registry[:one] = one
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do |input|
        one(input)
        raise "It doesn't pop up"
      end
    end.new

    expect { instance.call(1).error! }.not_to raise_error
  end

  it 'accepts anything responding to call as steps' do
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
      include Spree::Transaction[registry: registry, db: false]

      transaction do |input|
        result_one = one(input)
        two(result_one)
      end
    end.new

    expect(instance.call(1).result!).to be(4)
  end

  it 'can inject steps on initialization' do
    default_one = ->(x) { Spree::Result.success(x + 1) }
    injected_one = ->(x) { Spree::Result.success(x + 2) }
    two = ->(x) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = default_one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do |input|
        result_one = one(input)
        two(result_one)
      end
    end.new(one: injected_one)

    expect(instance.call(1).result!).to be(5)
  end

  it 'can pass addional positional arguments to steps' do
    one = ->(x) { Spree::Result.success(x + 1) }
    two = ->(x) { Spree::Result.success(x + 2) }
    three = ->(x, y) { Spree::Result.success(x + y + 3) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    registry[:three] = three
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do |input|
        result_one = one(input)
        result_two = two(result_one)
        three(result_one, result_two)
      end
    end.new

    expect(instance.call(1).result!).to be(9)
  end

  it 'can pass keyword arguments to steps' do
    one = ->(x:) { Spree::Result.success(x + 1) }
    two = ->(x:) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do |input|
        result_one = one(x: input)
        two(x: result_one)
      end
    end.new

    expect(instance.call(1).result!).to be(4)
  end

  it 'can pass addional positional arguments to the transaction' do
    one = ->(x) { Spree::Result.success(x + 1) }
    two = ->(x) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do |x, z|
        result_one = one(x + z)
        two(result_one)
      end
    end.new

    expect(instance.call(1, 1).result!).to be(5)
  end

  it 'can pass keyword arguments to the transaction' do
    one = ->(x) { Spree::Result.success(x + 1) }
    two = ->(x) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do |x:|
        result_one = one(x)
        two(result_one)
      end
    end.new

    expect(instance.call(x: 1).result!).to be(4)
  end

  it 'accepts steps taking no output' do
    one = ->(x) { Spree::Result.success(x + 1) }
    two = -> { Spree::Result.success(3) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do
        result_one = one(1)
        two()
      end
    end.new

    expect(instance.call(1).result!).to be(3)
  end

  it 'accepts transactions taking no output' do
    one = -> { Spree::Result.success(1) }
    two = ->(x) { Spree::Result.success(x + 1) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do
        result_one = one()
        two(result_one)
      end
    end.new

    expect(instance.call.result!).to be(2)
  end

  it 'coerces step outputs to result' do
    one = lambda do |input|
      Class.new do
        def initialize(value)
          @value = value
        end

        def to_result
          Spree::Result.success(@value)
        end
      end.new(input)
    end
    two = ->(x) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do |input|
        result_one = one(1)
        two(result_one)
      end
    end.new

    expect(instance.call(1).result!).to be(3)
  end

  it 'can call a step without unwrapping' do
    one = ->() { "1" }
    two = ->(x) { Spree::Result.success(x + 2) }
    registry = {}
    registry[:one] = one
    registry[:two] = two
    instance = Class.new do
      include Spree::Transaction[registry: registry, db: false]

      transaction do |input|
        result_one = raw { one() }.to_i
        two(result_one)
      end
    end.new

    expect(instance.call.result!).to be(3)
  end

  it "aborts a database transaction when therea's a failure" do
    one = ->() { Spree::Result.success(create(:product)) }
    two = ->() { Spree::Result.failure(:error) }
    registry = {}
    registry[:one] = one
    registry[:two] = two

    instance = Class.new do
      include Spree::Transaction[registry: registry, db: true]

      transaction do |input|
        one()
        two()
      end
    end.new

    expect { instance.call }.not_to change { Spree::Product.count }
  end

  it "returns last failure when wrapped in a database transaction" do
    one = ->() { Spree::Result.success(create(:product)) }
    two = ->() { Spree::Result.failure(:error) }
    registry = {}
    registry[:one] = one
    registry[:two] = two

    instance = Class.new do
      include Spree::Transaction[registry: registry, db: true]

      transaction do |input|
        one()
        two()
      end
    end.new

    expect(instance.call.error!).to be(:error)
  end
end
