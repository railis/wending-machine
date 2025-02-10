module WendingMachine
  class Session

    attr_reader :cash_register, :inserted_coins, :stock

    def initialize(products:, coins:)
      @stock = Inventory.new(products)
      @cash_register = Inventory.new(coins)
      @inserted_coins = Inventory.new(coins.map {|c| c.merge(quantity: 0)})
    end

    def can_checkout?(product_name)
      return [false, :product_out_of_stock] if @stock.quantity(product_name) == 0
      return [false, :not_enough_cash] if @stock.price(product_name) > @inserted_coins.total_value
      return [false, :no_change] if @inserted_coins.total_value > @stock.price(product_name) && !calculate_change(product_name)

      return [true, nil]
    end

    def checkout!(product_name)
      return false unless can_checkout?(product_name)

      change = calculate_change(product_name)
      @stock.remove(product_name)
      @cash_register.merge!(@inserted_coins)
      @inserted_coins.clear_quantities!
      change.each do |coin, quantity|
        @cash_register.remove(coin.to_s, quantity: quantity)
      end
      Inventory.new(change.map {|v,q| {value: v, quantity: q}})
    end

    private

    def calculate_change(product_name)
      coins = {}.tap do |res|
        (@inserted_coins.list + @cash_register.list).each do |item|
          res[item[:value]] ||= 0
          res[item[:value]] += item[:quantity]
        end
      end
      Change.new(
        amount: @inserted_coins.total_value - @stock.price(product_name),
        coins: coins
      ).calculate
    end

  end
end
