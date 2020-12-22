require './test/test_helper.rb'

class CliBuilderTest < Minitest::Test
  def test_parse_input_with_0_options
    prompt = CliBuilder::Prompt.new

    prompt.register_command(:command1) do
    end

    result = prompt.send(:parse_input, 'command1')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command1, result.command)
    assert_empty(result.options)

    result = prompt.send(:parse_input, 'com1')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnknownCommand, result)
    assert_equal(:com1, result.command)

    result = prompt.send(:parse_input, 'command1 extra_input')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnexpectedToken, result)
    assert_equal('extra_input', result.token)
  end

  def test_parse_input_with_1_required_option
    prompt = CliBuilder::Prompt.new

    prompt.register_command(:command, '<name>') do
    end

    result = prompt.send(:parse_input, 'command joe')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command, result.command)
    assert_equal('joe', result.options.name)

    result = prompt.send(:parse_input, 'command')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::MissingArguments, result)
    assert_equal('<name>', result.arguments[0].to_s)

    result = prompt.send(:parse_input, 'command joe blow')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnexpectedToken, result)
    assert_equal('blow', result.token)
  end

  def test_parse_input_with_1_optional_option
    prompt = CliBuilder::Prompt.new

    prompt.register_command(:command, '[NAME name]') do
    end

    result = prompt.send(:parse_input, 'command')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command, result.command)
    assert_empty(result.options)

    result = prompt.send(:parse_input, 'command joe')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnexpectedToken, result)
    assert_equal('joe', result.token)

    result = prompt.send(:parse_input, 'command NAME joe')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command, result.command)
    assert_equal('joe', result.options.name)

    result = prompt.send(:parse_input, 'command joe blow')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnexpectedToken, result)
    assert_equal('joe', result.token)

    result = prompt.send(:parse_input, 'command NAME joe blow')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnexpectedToken, result)
    assert_equal('blow', result.token)
  end

  def test_parse_input_with_complex_options_1
    prompt = CliBuilder::Prompt.new

    prompt.register_command(:command, '[FOO1 foo1] <foo2>') do
    end

    result = prompt.send(:parse_input, 'command FOO1 apple banana')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command, result.command)
    assert_equal('apple', result.options.foo1)
    assert_equal('banana', result.options.foo2)

    result = prompt.send(:parse_input, 'command FOO2 apple banana')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnexpectedToken, result)
    assert_equal('apple', result.token)

    result = prompt.send(:parse_input, 'command FOO1 apple')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::MissingArguments, result)
    assert_equal('<foo2>', result.arguments[0].to_s)

    result = prompt.send(:parse_input, 'command FOO1 apple banana carrot')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnexpectedToken, result)
    assert_equal('carrot', result.token)

    result = prompt.send(:parse_input, 'command banana FOO1 apple')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnexpectedToken, result)
    assert_equal('FOO1', result.token)

    result = prompt.send(:parse_input, 'command1 FOO1 apple banana')
    assert(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Errors::UnknownCommand, result)
    assert_equal(:command1, result.command)
  end

  def test_parse_input_with_complex_options_2
    prompt = CliBuilder::Prompt.new

    prompt.register_command(:command, 'command <foo1> [FOO2 foo2] [FOO3 foo3] <FOO4 foo4> [FOO5 foo5]') do
    end

    # 0 0 0
    result = prompt.send(:parse_input, 'command apple FOO4 banana')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal('apple', result.options.foo1)
    assert_equal('banana', result.options.foo4)

    # 0 0 1
    result = prompt.send(:parse_input, 'command apple FOO4 banana FOO5 carrot')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal('apple', result.options.foo1)
    assert_equal('banana', result.options.foo4)
    assert_equal('carrot', result.options.foo5)

    # 0 1 0
    result = prompt.send(:parse_input, 'command apple FOO3 banana FOO4 carrot')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal('apple', result.options.foo1)
    assert_equal('banana', result.options.foo3)
    assert_equal('carrot', result.options.foo4)

    # 0 1 1
    result = prompt.send(:parse_input, 'command apple FOO3 banana FOO4 carrot FOO5 dill_pickle')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal('apple', result.options.foo1)
    assert_equal('banana', result.options.foo3)
    assert_equal('carrot', result.options.foo4)
    assert_equal('dill_pickle', result.options.foo5)

    # 1 0 0
    result = prompt.send(:parse_input, 'command apple FOO2 banana FOO4 carrot')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal('apple', result.options.foo1)
    assert_equal('banana', result.options.foo2)
    assert_equal('carrot', result.options.foo4)

    # 1 0 1
    result = prompt.send(:parse_input, 'command apple FOO2 banana FOO4 carrot FOO5 dill_pickle')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal('apple', result.options.foo1)
    assert_equal('banana', result.options.foo2)
    assert_equal('carrot', result.options.foo4)
    assert_equal('dill_pickle', result.options.foo5)

    # 1 1 0
    result = prompt.send(:parse_input, 'command apple FOO2 banana FOO3 carrot FOO4 dill_pickle')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal('apple', result.options.foo1)
    assert_equal('banana', result.options.foo2)
    assert_equal('carrot', result.options.foo3)
    assert_equal('dill_pickle', result.options.foo4)

    # 1 1 1
    result = prompt.send(:parse_input, 'command apple FOO2 banana FOO3 carrot FOO4 dill_pickle FOO5 edelweiss')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal('apple', result.options.foo1)
    assert_equal('banana', result.options.foo2)
    assert_equal('carrot', result.options.foo3)
    assert_equal('dill_pickle', result.options.foo4)
    assert_equal('edelweiss', result.options.foo5)
  end

  def test_parse_input_with_upcase_value_name
    prompt = CliBuilder::Prompt.new

    prompt.register_command(:command, '[NAME NaMe]') do
    end

    result = prompt.send(:parse_input, 'command NAME joe')
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_equal(:command, result.command)
    assert_equal('joe', result.options.name)
  end

  def test_command_syntax_errors
    prompt = CliBuilder::Prompt.new

    assert_raises(CliBuilder::Syntax::Error) do
      prompt.register_command(:command, '[JOB]')
    end

    assert_raises(CliBuilder::Syntax::Error) do
      prompt.register_command(:command, 'name [JOB]')
    end

    assert_raises(CliBuilder::Syntax::Error) do
      prompt.register_command(:command, 'name <AGE age> [JOB]')
    end

    assert_raises(CliBuilder::Syntax::Error) do
      prompt.register_command(:command, 'name <age> [JOB job1 job2]')
    end
  end

  def test_command_with_dashes
    prompt = CliBuilder::Prompt.new

    prompt.register_command(:'list-foos') do
    end

    result = prompt.send(:parse_input, 'list-foos')
    refute_nil(result)
    refute(result.error?)
    assert_instance_of(CliBuilder::Input::Parse::Result, result)
    assert_empty(result.options)
  end
end
