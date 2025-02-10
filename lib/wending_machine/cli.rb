require "io/console"
require "ttyhue"
require "tty-table"
require "tty-cursor"

module WendingMachine
  class Cli

    class << self

      def run(session)
        TTYHue.set_style(
          product_header: {fg: :gui141},
          product: {fg: :gui230},
          product_active: {fg: :gui156},
          product_out_of_stock: {fg: :gui240},
          keybinding: {fg: :gui206},
          keybinding_label: {fg: :gui218},
          statusline_key: {fg: :gui203},
          statusline_val: {fg: :gui220},
          negative_balance: {fg: :gui160},
          positive_balance: {fg: :gui158},
          message: {fg: :gui153},
          error: {fg: :gui196}
        )
        system("clear")
        state = State.new(session)
        screen = Screen.new(state)
        print TTY::Cursor.hide
        loop do
          screen.redraw!
          case k = Keycapture.get
          when :ctrl_c
            print TTY::Cursor.show
            exit 0
          else
            state.handle_key(k)
          end
          screen.redraw!
        end
      end

    end

  end
end
