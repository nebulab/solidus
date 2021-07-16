# frozen_string_literal: true

require 'spree/event/event'

RSpec.describe Spree::Event::Event do
  describe '#initialize' do
    it "sets its time attribute" do
      event = described_class.new

      expect(event.time).to be_a(Time)
    end

    it "sets its caller_location from given argument" do
      event = described_class.new(caller_location: caller_locations(0, 1)[0])

      expect(event.caller_location.to_s).to include(__FILE__)
    end
  end
end
