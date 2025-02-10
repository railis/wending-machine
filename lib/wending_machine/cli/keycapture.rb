module WendingMachine
  class Cli
    class Keycapture

      class << self

        def get
          case c = read_char
          when "\u0003"
            :ctrl_c
          when "\e[A"
            :down_arrow
          when "\e[B"
            :up_arrow
          when "\r"
            :return
          when /^.$/
            :"key_#{c}"
          end
        end

        private

        def read_char
          STDIN.echo = false
          STDIN.raw!

          input = STDIN.getc.chr
          if input == "\e" then
            input << STDIN.read_nonblock(3) rescue nil
            input << STDIN.read_nonblock(2) rescue nil
          end
        ensure
          STDIN.echo = true
          STDIN.cooked!

          return input
        end

      end

    end
  end
end
