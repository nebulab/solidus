# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator::PercentOnLineItem < Calculator
    preference :percent, :decimal, default: 0

    def compute(object)
      object_amount = object.running_total ? (object.amount - object.running_total.abs) : object.amount
      (object_amount * preferred_percent) / 100
      #(object.amount * preferred_percent) / 100
    end
  end
end
