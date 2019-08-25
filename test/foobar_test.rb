require './test/test_helper.rb'

class FoobarTest < Minitest::Test
  def test_no_options
    prompt = CliBuilder::Prompt.new

    prompt.register_command(:command1) do
    end

    result = prompt.parse_input('command1')
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command1, result.command)
    assert_empty(result.options)

    result = prompt.parse_input('com1')
    assert_instance_of(CliBuilder::Input::Parse::Error, result)
    assert(result.unknown_command?)

    result = prompt.parse_input('command1 extra_input')
    assert_instance_of(CliBuilder::Input::Parse::Error, result)
    assert(result.unexpected_token?)
  end

  def test_foobar
    prompt = CliBuilder::Prompt.new


    prompt.register_command(:command2, '<name>') do
    end

    prompt.register_command(:command3, '<name name>') do
    end

    prompt.register_command(:command4, '<NAME name> <age>') do
    end

    prompt.register_command(:command5, '<NAME name> [JOB job]') do
    end


    result = prompt.parse_input('command2 foobar')
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command2, result.command)
    assert_equal('foobar', result.options.name)

    result = prompt.parse_input('command3 name foobar')
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command3, result.command)
    assert_equal('foobar', result.options.name)

    result = prompt.parse_input('command4 NAME foobar 32')
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command4, result.command)
    assert_equal('foobar', result.options.name)
    assert_equal('32', result.options.age)
  end
end
