module WendingMachine
  class Cli
    class State
      include Helper

      attr_reader :session, :selected_product, :selected_index, :message

      def initialize(session)
        @session = session
        @state_name = :default
        set_message("Please select action using keyboard")
      end

      def available_key_bindings
        case @state_name
        when :default
          [
            [:key_p, "Select product", :go_select_product, nil],
            [:key_i, "Insert coins", :go_insert_coins, nil],
            ([:return, "Checkout", :checkout, nil] if @selected_product && inserted_coins.size > 0)
          ].compact
        when :select_product
          [
            [:up_arrow, "Move up", :product_up, nil],
            [:down_arrow, "Move down", :product_down, nil],
            [:return, "Select", :product_select, nil],
            [:key_b, "Back", :back, nil],
            [:key_c, "Cancel", :cancel, nil]
          ]
        when :insert_coins
          @session.inserted_coins.names.map.with_index do |c, idx|
            [:"key_#{idx+1}", "#{c}", :insert_coin, c]
          end + [
            [:key_b, "Back", :back, nil],
            [:key_c, "Cancel", :cancel, nil]
          ]
        end + [
          [:key_q, "Exit", :exit, nil],
        ]
      end

      def handle_key(type)
        key_binding = available_key_bindings.select {|b| b[0] == type}.first
        return unless key_binding

        handle_action(key_binding[2], key_binding[3])
      end

      def handle_action(action, value)
        case action
        when :go_select_product
          set_message("Select product using arrow keys")
          @state_name = :select_product
          @selected_index = 0
        when :product_up
          @selected_index +=1
        when :product_down
          @selected_index -=1
        when :product_select
          product = @session.stock.list[@selected_index % @session.stock.list.size]
          if product[:quantity] > 0
            @selected_product = product[:name]
          else
            set_message("Product #{product[:name]} out-of-stock", error: true)
          end
          @selected_index = nil
          @state_name = :default
        when :go_insert_coins
          set_message("Select coins using corresponding num keys")
          @state_name = :insert_coins
        when :insert_coin
          @session.inserted_coins.add(value, quantity: 1)
        when :cancel
          @selected_product = nil
          @session.inserted_coins.clear_quantities!
          set_message("Please select action using keyboard")
          @state_name = :default
        when :back
          set_message("Please select action using keyboard")
          @state_name = :default
        when :checkout
          checkout
        when :exit
          puts TTY::Cursor.show
          exit 0
        end
      end

      def checkout
        can, error = @session.can_checkout?(@selected_product)
        if can
          change = @session.checkout!(@selected_product)
          set_message("Yey, you bought one #{@selected_product}. Here is the change: #{format_coins(change)}")
        else
          case error
          when :no_change
            set_message("Not enough change. Returning coins: #{format_coins(@session.inserted_coins)}")
          end
        end
        @session.inserted_coins.clear_quantities!
        @selected_product = nil
      end

      def set_message(msg, error: false)
        hue_class = error ? "error" : "message"
        @message = "{#{hue_class}}#{msg}{/#{hue_class}}"
      end

      def inserted_coins
        @session.inserted_coins.list.select do |c|
          c[:quantity] > 0
        end
      end

    end
  end
end
