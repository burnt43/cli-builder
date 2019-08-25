require './test/test_helper.rb'

class FoobarTest < Minitest::Test
  def test_foobar
    prompt = CliBuilder::Prompt.new('test >')

    prompt.register_command(:command1) do
      # noop
    end

    prompt.register_command(:command2, '<name>') do
      # noop
    end

    prompt.register_command(:command3, '<name name>') do
      # noop
    end

    prompt.register_command(:command4, '<NAME name> <age>') do
      # noop
    end

    prompt.register_command(:command5, '<NAME name> [JOB job]') do
      # noop
    end

    result = prompt.parse_input('command1')
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command1, result.command)
    assert_empty(result.options)

    result = prompt.parse_input('command2 foobar')

    result = prompt.parse_input('command3 name foobar')

    result = prompt.parse_input('command4 NAME foobar 32')
  end
end
