require './test/test_helper.rb'

class FoobarTest < Minitest::Test
  def test_parse_input_with_0_options
    prompt = CliBuilder::Prompt.new

    prompt.register_command(:command1) do
    end

    result = prompt.parse_input('command1')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command1, result.command)
    assert_empty(result.options)

    result = prompt.parse_input('com1')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnknownCommand, result)
    assert_equal(:com1, result.command)

    result = prompt.parse_input('command1 extra_input')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnexpectedToken, result)
    assert_equal('extra_input', result.token)
  end

  def test_parse_input_with_1_required_option
    prompt = CliBuilder::Prompt.new

    prompt.register_command(:command, '<name>') do
    end

    result = prompt.parse_input('command joe')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command, result.command)
    assert_equal('joe', result.options.name)

    result = prompt.parse_input('command')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::MissingArguments, result)
    assert_equal('<name>', result.arguments[0].to_s)
  end

  def test_foobar
#     prompt = CliBuilder::Prompt.new
# 
# 
#     prompt.register_command(:command2, '<name>') do
#     end
# 
#     prompt.register_command(:command3, '<name name>') do
#     end
# 
#     prompt.register_command(:command4, '<NAME name> <age>') do
#     end
# 
#     prompt.register_command(:command5, '<NAME name> [JOB job]') do
#     end
# 
# 
#     result = prompt.parse_input('command2 foobar')
#     assert_instance_of(CliBuilder::Input::Parse::Result, result)
#     assert_equal(:command2, result.command)
#     assert_equal('foobar', result.options.name)
# 
#     result = prompt.parse_input('command3 name foobar')
#     assert_instance_of(CliBuilder::Input::Parse::Result, result)
#     assert_equal(:command3, result.command)
#     assert_equal('foobar', result.options.name)
# 
#     result = prompt.parse_input('command4 NAME foobar 32')
#     assert_instance_of(CliBuilder::Input::Parse::Result, result)
#     assert_equal(:command4, result.command)
#     assert_equal('foobar', result.options.name)
#     assert_equal('32', result.options.age)
  end
end
