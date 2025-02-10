require_relative "../test_helper"

describe WendingMachine::Session do

  context "#initialize" do

    should "initialize inventories for session" do
      products = [
        {name: "Cola", value: 2.0, quantity: 3},
        {name: "Water", value: 1.0, quantity: 2}
      ]
      coins = [
        {value: 5.0, quantity: 3},
        {value: 2.0, quantity: 2},
        {value: 0.5, quantity: 2}
      ]
      session = WendingMachine::Session.new(products: products, coins: coins)

      assert_equal(products, session.stock.list)
      assert_equal(coins.map {|c| c.merge(name: c[:value].to_s)}, session.cash_register.list)
    end

  end

  context "#can_checkout?" do

    setup do
      products = [
        {name: "Cola", value: 5.0, quantity: 3},
        {name: "Water", value: 3.0, quantity: 2},
        {name: "Candybar", value: 2.0, quantity: 0}
      ]
      coins = [
        {value: 5.0, quantity: 3},
        {value: 2.0, quantity: 3},
        {value: 0.5, quantity: 3}
      ]
      @test_checkout = ->(session, product_name, coins) {
        coins.each do |value, quantity|
          session.inserted_coins.add(value.to_s, quantity: quantity)
        end
        result = session.can_checkout?(product_name)
        session.inserted_coins.clear_quantities!
        result
      }
      @session = WendingMachine::Session.new(products: products, coins: coins)
    end

    context "when transaction can be made" do

      should "return true and no message when given exact amount" do
        assert_equal [true, nil], @test_checkout.(@session, "Cola", {5.0 => 1})
        assert_equal [true, nil], @test_checkout.(@session, "Cola", {2.0 => 2, 0.5 => 2})
      end

      should "return true and no message when given amount bigger than needed" do
        assert_equal [true, nil], @test_checkout.(@session, "Cola", {2.0 => 3})
        assert_equal [true, nil], @test_checkout.(@session, "Cola", {2.0 => 2, 0.5 => 6})
      end

    end

    context "when transaction cannot be made" do

      should "return false and message when trying to buy out of stock product" do
        assert_equal [false, :product_out_of_stock], @test_checkout.(@session, "Candybar", {5.0 => 3})
      end

      should "return false and message when trying to buy product with insufficient funds" do
        assert_equal [false, :not_enough_cash], @test_checkout.(@session, "Cola", {0.5 => 3, 2.0 => 1})
      end

      should "return false and message when there is not enough change" do
        @session.cash_register.remove("5.0", quantity: 2)
        @session.cash_register.remove("2.0", quantity: 3)
        assert_equal [false, :no_change], @test_checkout.(@session, "Water", { 5.0 => 1 })
      end

    end

  end

  context "#checkout!" do

    setup do
      products = [
        {name: "Cola", value: 5.0, quantity: 3},
        {name: "Water", value: 3.0, quantity: 2},
        {name: "Candybar", value: 2.0, quantity: 0}
      ]
      coins = [
        {value: 5.0, quantity: 3},
        {value: 2.0, quantity: 3},
        {value: 0.5, quantity: 3}
      ]
      @session = WendingMachine::Session.new(products: products, coins: coins)
    end

    should "update inventories and return change" do
      @session.inserted_coins.add("5.0", quantity: 1)
      change = @session.checkout!("Water")

      assert_equal 1, @session.stock.quantity("Water")
      assert_equal 4, @session.cash_register.quantity("5.0")
      assert_equal 2, @session.cash_register.quantity("2.0")
      assert_equal [{:name=>"2.0", :value=>2.0, :quantity=>1}], change.list
    end

  end

end
