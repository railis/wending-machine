module WendingMachine
  class Cli
    module Helper

      def format_coins(inventory)
        filtered = inventory.list.select {|e| e[:quantity] > 0}
        if filtered.empty?
          "{statusline_val}none{/statusline_val}"
        else
          filtered.map do |c|
            "{statusline_val}#{c[:value]}{product}x#{c[:quantity]}{/product}{/statusline_val}"
          end.join(" ") 
        end
      end

    end
  end
end
