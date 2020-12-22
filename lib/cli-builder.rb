require 'hashie'

module CliBuilder
  module Success
    def error?
      false
    end
  end

  module Error
    def error?
      true
    end
  end

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
            return Input::Parse::Errors::UnexpectedToken.new(token)
          end

          if argument.required
            if expecting_keyword && argument.keyword
              if token == argument.keyword
                expecting_keyword = false
              else
                return Input::Parse::Errors::UnexpectedToken.new(token)
              end
            else
              options.send("#{argument.value_name.downcase}=", token)
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
              options.send("#{argument.value_name.downcase}=", token)
              index += 1
              expecting_keyword = true
            end
          end
        end

        missing_required_arguments = @arguments[index..-1]&.select(&:required) || []

        unless missing_required_arguments.empty?
          return Input::Parse::Errors::MissingArguments.new(missing_required_arguments)
        end

        options
      end
    end

    Argument = Struct.new(:value_name, :keyword, :required) do
      def to_s
        result = StringIO.new
        result.print(required ? '<' : '[')
        if keyword
          result.print(keyword) 
          result.print(' ')
        end
        result.print value_name
        result.print(required ? '>' : ']')

        result.string
      end
    end
    Error = Class.new(StandardError)
  end # Syntax

  module Input
    module Parse
      Options = Class.new(Hashie::Mash)

      Result = Struct.new(:command, :options) do
        include CliBuilder::Success
      end

      module Errors
        MissingArguments = Struct.new(:arguments) do
          include CliBuilder::Error
        end

        UnexpectedToken = Struct.new(:token) do
          include CliBuilder::Error
        end

        UnknownCommand = Struct.new(:command) do
          include CliBuilder::Error
        end
        
        BadInput = Struct.new(:input) do
          include CliBuilder::Error
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
      @error_handler = lambda { |error| puts "an error occurred: #{error}" }
      @exit_flag = false
      @tab_space = '..'
    end

    def register_command(command_name, syntax_string = nil, &block)
      syntax_parse_data = CliBuilder::Syntax::Parser.new(syntax_string).parse
      @commands[command_name.to_sym] = CommandData.new(syntax_parse_data, (lambda &block))
    end

    def register_error_handler(&block)
      @error_handler = block
    end

    def run
      loop do
        break if @exit_flag

        print "#{@prompt_string} "
        user_input = gets.chomp

        if user_input == @exit_string
          exit_prompt!
        else
          parsed_input = parse_input(user_input)

          if parsed_input.error?
            @error_handler.call(parsed_input)
          else
            if (command_data = @commands[parsed_input.command])
              command_data.callback.call(parsed_input)
            else
              # noop?
            end
          end
        end
      end
    end

    def yes_no_prompt(message=nil, &block)
      print "#{@tab_space}#{message}(Y/n) > "
      user_input = gets.chomp

      if user_input == 'Y' || user_input == 'y'
        block.call(true)
      else
        block.call(false)
      end
    end

    def value_prompt(message=nil, &block)
      print "#{@tab_space}#{message} > "
      user_input = gets.chomp

      block.call(user_input)
    end

    def exit_prompt!
      @exit_flag = true
    end

    # I/O Delegation Methods
    %i[
      puts
      print
      printf
    ].each do |method_name|
      define_method method_name do |*args|
        STDOUT.send(method_name, *args)
      end
    end

    private

    def parse_input(input_string)
      match_data = /\A(\S+)( (.*))?\z/.match(input_string)

      return Input::Parse::Errors::BadInput.new(input_string) unless match_data

      potential_command = match_data.captures[0].to_sym
      potential_options = match_data.captures[2] || ''

      command_data = @commands[potential_command]

      unless command_data
        return Input::Parse::Errors::UnknownCommand.new(potential_command)
      end

      if command_data.syntax_parse_data
        result = command_data.syntax_parse_data.options_from_input(potential_options)

        if result.error?
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

  end
end
