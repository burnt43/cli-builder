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
          # puts "(#{parse_state})[#{c}]"
          case parse_state
          when :looking_for_arguments
            if /\s/ =~ c
              # noop
            elsif c == '<'
              parse_state = :parsing_required_argument_string1
            elsif c == '['
              parse_state = :parsing_optional_argument_string1
            end
          when :parsing_optional_argument_string1
            if /\w/ =~ c
              string1.concat(c)
            elsif /\s/ =~ c
              parse_state = :parsing_optional_argument_string2
            else
              raise Error.new("invalid char: #{c}")
            end
          when :parsing_optional_argument_string2
            if /\w/ =~ c
              string2.concat(c)
            elsif c == ']'
              parse_state = :looking_for_arguments

              data.add_scalar_argument(string2.clone, keyword: string1.clone, required: false)
              string1.clear
              string2.clear
            else
              raise Error.new("invalid char: #{c}")
            end
          when :parsing_required_argument_string1
            if /\w/ =~ c
              string1.concat(c)
            elsif /\s/ =~ c
              parse_state = :parsing_required_argument_string2
            elsif c == '>'
              parse_state = :looking_for_arguments

              data.add_scalar_argument(string1.clone, required: true)
              string1.clear
              string2.clear
            else
              raise Error.new("invalid char: #{c}")
            end
          when :parsing_required_argument_string2
            if /\w/ =~ c
              string2.concat(c)
            elsif c == '>'
              parse_state = :looking_for_arguments

              data.add_scalar_argument(string2.clone, keyword: string1.clone, required: true)
              string1.clear
              string2.clear
            else
              raise Error.new("invalid char: #{c}")
            end
          end
        end

        data
      end
    end

    class Data
      def initialize
        @arguments = []
      end

      def add_scalar_argument(value_name, keyword: nil, required: false)
        @arguments.push(Argument.new(value_name, keyword, required))
      end

      def options_from_input(input_string)
        options = Input::Parse::Options.new

        return options unless input_string

        index = 0
        expecting_keyword = true

        input_string.split.each do |token|
          argument = @arguments[index]

          unless argument
            return Input::Parse::Error.new(:unexpected_token, "\"#{token}\"")
          end

          if argument.required
            if expecting_keyword && argument.keyword
              if token == argument.keyword
                expecting_keyword = false
              else
                return Input::Parse::Error.new(:unexpected_token, "\"#{token}\"")
              end
            else
              options.send("#{argument.value_name}=", token)
              index += 1
              expecting_keyword = true
            end
          else
            if expecting_keyword
              if argument.keyword != token
                index +=1
                expecting_keyword = true
                redo
              else
                expecting_keyword = false
              end
            else
              options.send("#{argument.value_name}=", token)
              index += 1
              expecting_keyword = true
            end
          end
        end

        options
      end
    end

    Argument = Struct.new(:value_name, :keyword, :required)
    Error = Class.new(StandardError)
  end

  module Input
    module Parse
      Options = Class.new(Hashie::Mash)
      Result = Struct.new(:command, :options)
      Error  = Struct.new(:type, :message) do
        NAMES = Set.new(%i[
          unknown_command
          unexpected_token
        ])

        def method_missing(method_name, *args, &block)
          if (match_data = /\A(\w+)\?\z/.match(method_name))
            error_name = match_data.captures[0].to_sym
            if NAMES.member?(error_name)
              type == error_name
            else
              super
            end
          else
            super
          end
        end
      end
    end
  end

  CommandData = Struct.new(:syntax_parse_data, :callback)

  class Prompt
    def initialize(
      prompt_string: 'prompt >',
      exit_string: 'exit'
    )
      @prompt_string = prompt_string
      @exit_string = exit_string
      @commands = {}
    end

    def register_command(command_name, syntax_string = nil, &block)
      syntax_parse_data = CliBuilder::Syntax::Parser.new(syntax_string).parse
      @commands[command_name.to_sym] = CommandData.new(syntax_parse_data, block)
    end

    def parse_input(input_string)
      match_data = /\A(\w+)( (.*))?\z/.match(input_string)

      return unless match_data

      potential_command = match_data.captures[0].to_sym
      potential_options = match_data.captures[2]

      command_data = @commands[potential_command]

      unless command_data
        return Input::Parse::Error.new(:unknown_command, "\"#{potential_command}\"")
      end

      if command_data.syntax_parse_data
        result = command_data.syntax_parse_data.options_from_input(potential_options)

        if result.is_a?(Input::Parse::Error)
          return result
        else
          Input::Parse::Result.new(
            potential_command,
            result
          )
        end
      else
        Input::Parse::Result.new(
          potential_command,
          Input::Parse::Options.new
        )
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
