require 'hashie'

module CliBuilder
  module Syntax
    class Parser
      def initialize(syntax_string)
        @syntax_string = syntax_string
      end

      def parse
        data = Data.new

        return data unless @syntax_string

        parse_state = :looking_for_arguments

        string1 = ''
        string2 = ''

        @syntax_string.each_char do |c|
          puts "(#{parse_state})[#{c}]"
          case parse_state
          when :looking_for_arguments
            if /\s/ =~ c
              # noop
            elsif c == '<'
              parse_state = :parsing_required_argument_string1
            elsif c == '['
               # TODO: optional arguments
            end
          when :parsing_required_argument_string1
            if /\w/ =~ c
              string1.concat(c)
            elsif /\s/ =~ c
              parse_state = :parsing_required_argument_string2
            elsif c == '>'
              parse_state = :looking_for_arguments

              data.add_scalar_argument(string1, required: true)
              string1.clear
              string2.clear
            else
              raise 'invalid'
            end
          when :parsing_required_argument_string2
            if /\w/ =~ c
              string2.concat(c)
            elsif c == '>'
              parse_state = :looking_for_arguments

              data.add_scalar_argument(string2, keyword: string1, required: true)
              string1.clear
              string2.clear
            else
              raise 'invalid'
            end
          end
        end

        data
      end
    end

    class Data
      def initialize
      end

      def add_scalar_argument(value_name, keyword: nil, required: false)
        puts "[JCARSON] - value_name: #{value_name}, keyword: #{keyword}"
      end

      def to_regex
      end
    end
  end

  module Input
    module Parse
      Options = Class.new(Hashie::Mash)
      Result = Struct.new(:command, :options)
      Error  = Struct.new(:type, :message) do
        # 1 UNKNOWN_COMMAND
      end
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
      CliBuilder::Syntax::Parser.new(syntax_string).parse
      @commands[command_name.to_sym] = CommandData.new(syntax_string, block)
    end

    def parse_input(input_string)
      match_data = /\A(\w+)( (.*))?\z/.match(input_string)

      return unless match_data

      potential_command = match_data.captures[0].to_sym
      potential_options = match_data.captures[2]
      puts "potential_options: #{potential_options}"

      command_data = @commands[potential_command]

      unless command_data
        return Input::Parse::Error.new(1, "unknown command: \"#{potential_command}\"")
      end

      if command_data.syntax_string
      else
        Input::Parse::Result.new(potential_command, Input::Parse::Options.new)
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
