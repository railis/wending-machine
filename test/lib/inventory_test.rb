require_relative "../test_helper"

describe WendingMachine::Inventory do

  context "#register" do

    setup do
      @inventory = WendingMachine::Inventory.new
    end

    context "correct input" do

      should "add product and it's value to registered items and set count to 0" do
        @inventory.register(name: "Cola", value: 2.0)
        expected = [
          {name: "Cola", value: 2.0, quantity: 0}
        ]
        assert_equal expected, @inventory.list
      end
      
    end

    context "incorrect input" do

      should "raise error when non positive value passed" do
        assert_raises WendingMachine::Inventory::NonPositiveValueError do
          @inventory.register(name: "Cola", value: -1)
        end
        assert_raises WendingMachine::Inventory::NonPositiveValueError do
          @inventory.register(name: "Cola", value: -1.2)
        end
      end

    end

  end

  context "#add" do

    setup do
      @inventory = WendingMachine::Inventory.new
      @inventory.register(name: "five", value: 5)
      @inventory.register(name: "two", value: 2)
      @inventory.register(name: "half", value: 0.5)
      @inventory.register(name: "quarter", value: 0.25)
    end

    context "correct input" do

      should "update the state" do
        @inventory.add("five", quantity: 4)
        @inventory.add("two", quantity: 2)
        @inventory.add("quarter")
        @inventory.add("quarter", quantity: 2)
        expected = [
          {name: "five", value: 5.0, quantity: 4},
          {name: "two", value: 2.0, quantity: 2},
          {name: "half", value: 0.5, quantity: 0},
          {name: "quarter", value: 0.25, quantity: 3}
        ]
        assert_equal expected, @inventory.list
      end

    end

    context "incorrect input" do

      should "raise error when used with unregistered item" do
        assert_raises WendingMachine::Inventory::UnregisteredItemError do
          @inventory.add("something else", quantity: 1)
        end
      end

      should "raise error when using non-positive quantity" do
        assert_raises WendingMachine::Inventory::NegativeQuantityError do
          @inventory.add("five", quantity: -1)
        end
      end

    end

  end

  context "#remove" do

    setup do
      @inventory = WendingMachine::Inventory.new
      @inventory.register(name: "five", value: 5)
      @inventory.register(name: "two", value: 2)
      @inventory.add("five", quantity: 2)
      @inventory.add("two")
    end

    context "correct input" do

      should "update the state" do
        @inventory.remove("five", quantity: 2)
        expected = [
          {name: "five", value: 5.0, quantity: 0},
          {name: "two", value: 2.0, quantity: 1}
        ]
        assert_same_elements expected, @inventory.list
      end

    end

    context "incorrect input" do

      should "raise error when used with unregistered item" do
        assert_raises WendingMachine::Inventory::UnregisteredItemError do
          @inventory.remove("something else", quantity: 1)
        end
      end

      should "raise error when using non-positive quantity" do
        assert_raises WendingMachine::Inventory::NegativeQuantityError do
          @inventory.remove("five", quantity: -1)
        end
      end

      should "raise error when trying to remove too much" do
        assert_raises WendingMachine::Inventory::InsufficientItemsError do
          @inventory.remove("five", quantity: 3)
        end
      end
    end

  end

  context "#merge!" do

    setup do
      @inventory1 = WendingMachine::Inventory.new(
        [
          {name: "Foo", value: 1.0, quantity: 1},
          {name: "Bar", value: 2.0, quantity: 2}
        ]
      )
      @inventory2 = WendingMachine::Inventory.new(
        [
          {name: "Foo", value: 1.0, quantity: 3},
          {name: "Bar", value: 2.0, quantity: 3}
        ]
      )
    end

    should "merge passed inventory" do
      @inventory1.merge!(@inventory2)
      expected = [
        {name: "Foo", value: 1.0, quantity: 4},
        {name: "Bar", value: 2.0, quantity: 5}
      ]
      assert_equal expected, @inventory1.list
    end

  end

  context "#clear_stock!" do

    setup do
      @inventory = WendingMachine::Inventory.new(
        [
          {name: "Foo", value: 1.0, quantity: 1},
          {name: "Bar", value: 2.0, quantity: 2}
        ]
      )
    end

    should "clear quantities" do
      @inventory.clear_quantities!
      expected = [
        {name: "Foo", value: 1.0, quantity: 0},
        {name: "Bar", value: 2.0, quantity: 0}
      ]
      assert_equal expected, @inventory.list
    end
  end

end
