module CliBuilder
  class Prompt
    def initialize(
      prompt_string,
      exit_string: 'exit'
    )
      @prompt_string = prompt_string
      @exit_string = exit_string
      @commands = {}
    end

    def on(string, &block)
      @commands[string] = block
    end

    def run
      loop do
        print "#{@prompt_string} "
        user_input = gets.chomp

        if user_input == @exit_string
          break
        elsif (block = @commands[user_input])
          block.call
        else
          puts "unknown command \"#{user_input}\""
        end
      end
    end
  end
end
