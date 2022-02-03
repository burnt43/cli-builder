require 'hashie'

class String
  def chunks_of_size(n)
    chunk_number = 0
    [].tap do |a|
      loop {
        lower = chunk_number * n
        upper = ((chunk_number + 1) * n) - 1

        substring = self[lower..upper]
        break unless substring

        a.push(substring)
        chunk_number += 1
      }
    end
  end
end

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
      attr_reader :arguments

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

  class CommandData
    attr_reader :syntax_parse_data
    attr_reader :help_data
    attr_reader :callback

    def initialize(syntax_parse_data, help_data, callback)
      @syntax_parse_data = syntax_parse_data
      @help_data = help_data
      @callback = callback
    end

    # instance methods
    def help_text
      help_data.command_help_text
    end

    def arguments
      syntax_parse_data.arguments
    end

    def argument_string
      arguments.each(&:to_s).join(' ')
    end

    def argument_help_text_lookup(argument)
      help_data.argument_help_text_lookup(argument)
    end

    class HelpData
      attr_reader :command_help_text

      def initialize(command_help_text, argument_help_map)
        @command_help_text = command_help_text
        @argument_help_map = argument_help_map
      end

      def argument_help_text_lookup(argument)
        return unless @argument_help_map

        lookup_key =
          if argument.is_a?(CliBuilder::Syntax::Argument)
            argument.value_name.to_sym
          else
            argument.to_sym
          end

        @argument_help_map[lookup_key]
      end
    end # HelpData
  end # CommandData

  class Prompt
    def initialize(
      prompt_string: 'prompt >',
      exit_string: 'exit',
      help_string: 'help',
      greeting_string: nil
    )
      @prompt_string = prompt_string
      @exit_string = exit_string
      @help_string = help_string
      @greeting_string = greeting_string

      @commands = {}

      @error_handler = ->(error) {
        puts "an error occurred: #{error}"
      }
      @help_handler = ->(command_help_map, help_args=nil) {
        max_width = 80
        tab_space = '    '
        command_help_map.each do |command_name, command_help_data|
          if help_args
            next unless command_name.to_s.include?(help_args)
          end

          printf("\033[0;32m%-15s\033[0;0m\n", command_name)
          printf("#{tab_space}%s\n", command_help_data[:argument_string])

          if command_help_data[:help_text]
            command_help_data[:help_text].chunks_of_size(max_width).each do |help_text_chunk|
              printf("#{tab_space*2}%s\n", help_text_chunk)
            end
          end

          command_help_data[:arguments].each do |argument_name, argument_help_data|
            printf("#{tab_space}\033[0;33m%-15s\033[0;0m\n", argument_name)

            if argument_help_data[:help_text]
              argument_help_data[:help_text].chunks_of_size(max_width).each do |help_text_chunk|
                printf("#{tab_space*2}%s\n", help_text_chunk)
              end
            end
          end
        end
      }

      @exit_flag = false

      @tab_space = '..'
    end

    def register_command(command_name, syntax_string = nil, command_help: nil, argument_help: nil, &block)
      syntax_parse_data = CliBuilder::Syntax::Parser.new(syntax_string).parse
      help_data = CliBuilder::CommandData::HelpData.new(command_help, argument_help)

      @commands[command_name.to_sym] = CliBuilder::CommandData.new(syntax_parse_data, help_data, (lambda &block))
    end

    def register_error_handler(&block)
      @error_handler = (lambda &block)
    end

    def register_help_handler(&block)
      @help_handler = (lambda &block)
    end

    # Parse and attempt to run a command directly without the REPL.
    def run_command(user_input)
      handle_user_input(user_input)
    end

    # Run the REPL.
    def run
      if @greeting_string
        puts @greeting_string
      end

      loop do
        break if @exit_flag

        print "#{@prompt_string} "
        user_input = gets.chomp
        handle_user_input(user_input)
      end
    end

    def yes_no_prompt(
      message=nil,
      execute_only_on_yes: true,
      force_yes: false,
      &block
    )

      if force_yes
        if execute_only_on_yes
          block.call
        else
          block.call(true)
        end
      else
        # get user input unless this prompt is being forced as yes,
        # then we don't need any feedback from the user.
        print "#{@tab_space}#{message}(Y/n) > "
        user_input = gets.chomp

        # check for recognized characters to interpret as a 'Yes'.
        if user_input == 'Y' || user_input == 'y'
          if execute_only_on_yes
            # call block with no arg because the user chose 'Yes' and we're
            # only calling block on yeses.
            block.call
          else
            # call given block with true since the user chose 'Yes'
            block.call(true)
          end
        else
          if execute_only_on_yes
            # do not call the given block, because the user chose 'No' and
            # we are only calling the block on yeses.
          else
            # call given block with false since the user chose 'No'
            block.call(false)
          end
        end
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

    def handle_user_input(user_input)
      if user_input == @exit_string
        exit_prompt!
      elsif @help_string && user_input.start_with?(@help_string)
        # If there is more input after the help_string, consider it as args for
        # the help handler.
        split_user_input = user_input.split
        help_args = split_user_input[1]

        call_help_handler(help_args)
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

    # Return a nested hash that represents the help text per command and
    # per argument of that command. Imagine we had a command defined
    # like 'command1 <FOO foo>', then the returned hash would look
    # something like this:
    # {
    #   command1: {
    #     help_text: 'This is command1's help text',
    #     argument_string: '<FOO foo>'
    #     arguments: {
    #       foo: {
    #         help_text: 'This is foo's help text'
    #       }
    #     }
    #   }
    # }
    def commands_help_map
      @commands.each_with_object({}) do |(command_name, command_data), command_hash|
        command_hash[command_name] = {
          help_text: command_data.help_text,
          argument_string: command_data.argument_string,
          arguments: command_data.arguments.each_with_object({}) do |argument, argument_hash|
            argument_hash[argument.value_name] = {
              help_text: command_data.argument_help_text_lookup(argument)
            }
          end
        }
      end
    end

    def call_help_handler(help_args=nil)
      @help_handler.call(commands_help_map, help_args)
    end

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
