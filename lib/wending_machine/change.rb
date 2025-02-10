module WendingMachine
  class Change
    
    def initialize(amount:, coins:)
      @amount = amount
      @coins = coins
    end

    def calculate
      # Convert amount to cents to avoid floating point issues
      amount_cents = (@amount * 100).round

      # Initialize dp table: [amount][used_coins] -> {amount of coins used, coin combination}
      dp = Array.new(amount_cents + 1) { {} }
      dp[0] = { {} => { count: 0, coins: {} } }

      # Sort coins in descending order for better performance
      denominations = @coins.keys.sort.reverse

      # Process each amount from 1 to target
      (1..amount_cents).each do |cents|
        denominations.each do |denom|
          coin_cents = (denom * 100).round
          next if coin_cents > cents

          # Look at previous amount (cents - coin_cents)
          dp[cents - coin_cents]&.each do |prev_used_coins, prev_result|
            # Check if we can use this coin (haven't exceeded its quantity)
            current_coin_usage = prev_used_coins[denom] || 0
            next if current_coin_usage >= @coins[denom]

            # Create new used_coins state
            new_used_coins = prev_used_coins.dup
            new_used_coins[denom] = current_coin_usage + 1

            # Create new coin combination
            new_coins = prev_result[:coins].dup
            new_coins[denom] = (new_coins[denom] || 0) + 1

            # Calculate new total coin count
            new_count = prev_result[:count] + 1

            # If this is a better solution (or first solution) for this amount and used_coins state
            if !dp[cents][new_used_coins] || dp[cents][new_used_coins][:count] > new_count
              dp[cents][new_used_coins] = { count: new_count, coins: new_coins }
            end
          end
        end
      end

      # Find solution with minimum number of coins
      return nil if dp[amount_cents].empty?

      best_solution = dp[amount_cents].min_by { |_, result| result[:count] }
      best_solution[1][:coins]
    end

  end
end
