#!/usr/local/ruby/ruby-2.5.3/bin/ruby -I ./lib

require 'cli-builder.rb'

prompt = CliBuilder::Prompt.new

prompt.register_command(:command1) do |result|
  puts result.to_s
end

prompt.register_command(:command2, '[FOO foo]') do |result|
  puts "foo: #{result.options&.foo}"
end

prompt.run
