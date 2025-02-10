module WendingMachine
  class Cli
    class Screen
      include Helper
      
      def initialize(state)
        @state = state
      end

      def redraw!
        print TTY::Cursor.move_to
        puts products
        puts footer
      end

      private

      def products
        TTY::Table.new(
          header: [
            "",
            "Product".ljust(60),
            "Price",
            "(x)"
          ].map {|h| TTYHue.c("{product_header}#{h}{/product_header}")},
          rows: product_list.map do |i|
            [
              "#{i[0]}.",
              i[1],
              {value: i[2], alignment: :center},
      {value: i[3], alignment: :center}
            ]
          end
        ).render(:ascii, rendering_opts)
      end

      def footer
        TTY::Table.new(
          rows: [
            [statusline],
            [keybindings],
            [message]
          ]
        ).render(:ascii, rendering_opts) do |r|
          r.border.separator = :each_row
        end
      end

      def keybindings
        @state.available_key_bindings.map do |type, label|
          TTYHue.c("{keybinding}#{pretty_key(type)}{/keybinding}: {keybinding_label}#{label}{/keybinding_label}")
        end.join(", ")
      end

      def statusline
        TTYHue.c("{statusline_key}Product:{/statusline_key} #{product}, {statusline_key}Coins:{/statusline_key} #{format_coins(@state.session.inserted_coins)} - #{balance}")
      end

      def product
        "{statusline_val}#{@state.selected_product || 'none'}{/statusline_val}"
      end

      def balance
        needed = @state.selected_product ? @state.session.stock.price(@state.selected_product) : 0.0
        provided = @state.session.inserted_coins.total_value
        hue_class = needed > provided ? "negative_balance" : "positive_balance"
        "{#{hue_class}}#{provided}/#{needed}{/#{hue_class}}"
      end

      def message
        TTYHue.c(@state.message)
      end

      def pretty_key(key_type)
        case key_type
        when :up_arrow
          "↑"
        when :down_arrow
          "↓"
        when :return
          "enter"
        else
          "#{key_type.to_s.gsub("key_", "")}"
        end
      end

      def product_list
        list = @state.session.stock.list
        list.map.with_index do |i, idx|
          hue_class =
            if @state.selected_index && (@state.selected_index % list.size) == idx
              "product_active"
            elsif i[:quantity] == 0
              "product_out_of_stock"
            else
              "product"
            end
          [
            idx + 1,
            i[:name],
            i[:value],
            i[:quantity]
          ].map {|e| TTYHue.c("{#{hue_class}}#{e}{/#{hue_class}}")}
        end
      end

      def rendering_opts
        {padding: [0, 2, 0, 2], width: 100, resize: true}
      end

    end
  end
end
