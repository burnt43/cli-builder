require 'cli-builder.rb'

prompt = CliBuilder::Prompt.new

prompt.register_command(:command1) do |result|
  puts result.to_s
end

prompt.register_command(:command2, '[FOO foo]') do |result|
  puts "foo: #{result.options&.foo}"
end

prompt.register_command(:command3) do |result|
  prompt.yes_no_prompt do |response|
    if response
      prompt.value_prompt do |value|
        puts "entered #{value}"
      end
    else
      puts 'NO'
    end
  end
end

prompt.register_command(:command4) do |result|
  prompt.exit_prompt!
end

prompt.run
