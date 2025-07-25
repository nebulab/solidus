# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::ConditionStore do
  it { is_expected.to belong_to(:store) }
  it { is_expected.to belong_to(:condition) }
end
