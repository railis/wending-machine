require_relative "../test_helper"

describe WendingMachine::Change do

  describe "#calculate" do

    context "when it is possible to compose change" do
      [
        {value: 4.0, coins: {3.0 => 5, 2.0 => 5, 1.0 => 5, 0.5 => 5, 0.25 => 5}, result: {3.0 => 1, 1.0 => 1}},
        {value: 16.75, coins: {3.0 => 5, 2.0 => 5, 1.0 => 5, 0.5 => 5, 0.25 => 5}, result: {3.0=>5, 1.0=>1, 0.5=>1, 0.25=>1}},
        # greedy algorithm killer
        {value: 8.0, coins: {5.0 => 3, 4.0 => 4, 2.0 => 5, 1.0 => 2}, result: {4.0 => 2}},
        # not enough big denominators
        {value: 100.0, coins: {10.0 => 4, 5.0 => 3, 2.0 => 4, 1.0 => 3, 0.5 => 4, 0.25 => 200}, result: {0.25=>128, 0.5=>4, 1.0=>3, 2.0=>4, 5.0=>3, 10.0=>4}}
      ].each do |example|
        should "return correct coins for value: #{example[:value]} and coins: #{example[:coins].inspect}" do
          assert_equal example[:result], WendingMachine::Change.new(amount: example[:value], coins: example[:coins]).calculate
        end
      end
    end

    context "when it's not possible to compose change" do
      [
        # value that can't be divided by smallest denominator
        {value: 7.1, coins: {3.0 => 5, 2.0 => 5, 1.0 => 5, 0.5 => 5, 0.25 => 5}},
        # insufficient coins
        {value: 8, coins: {3.0 => 1, 2.0 => 1, 1.0 => 1, 0.5 => 1, 0.25 => 1}}
      ].each do |example|
        should "return nil for value: #{example[:value]} and coins: #{example[:coins].inspect}" do
          assert_nil WendingMachine::Change.new(amount: example[:value], coins: example[:coins]).calculate
        end
      end
    end

  end

end
