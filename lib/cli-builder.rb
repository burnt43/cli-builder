require 'hashie'

module CliBuilder
  module Parse
    Options = Class.new(Hashie::Mash)
    Result = Struct.new(:command, :options)
    Error  = Struct.new(:type, :message) do
      # 1 UNKNOWN_COMMAND
    end
  end

  CommandData = Struct.new(:syntax_string, :callback)

  class Prompt
    def initialize(
      prompt_string,
      exit_string: 'exit'
    )
      @prompt_string = prompt_string
      @exit_string = exit_string
      @commands = {}
    end

    def register_command(command_name, syntax_string = nil, &block)
      @commands[command_name.to_sym] = CommandData.new(syntax_string, block)
    end

    def parse_input(input_string)
      match_data = /\A(\w+) (.*)\z/.match(input_string)

      return unless match_data

      potential_command = match_data.captures[0].to_sym
      potential_options = match_data.captures[1]

      command_data = @commands[potential_command]

      unless command_data
        return Parse::Error.new(1, "unknown command: \"#{potential_command}\"")
      end

      if command_data.syntax_string
      else
        Parse::Result.new(potential_command, Options.new)
      end
    end

#     def run
#       loop do
#         print "#{@prompt_string} "
#         user_input = gets.chomp
# 
#         if user_input == @exit_string
#           break
#         elsif (block = @commands[user_input])
#           block.call
#         else
#           puts "unknown command \"#{user_input}\""
#         end
#       end
#     end
  end
end
