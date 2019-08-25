require './test/test_helper.rb'

class FoobarTest < Minitest::Test
  def test_foobar
    prompt = CliBuilder::Prompt.new('test >')
    prompt.register_command(:command1) do
      # noop
    end

    result = prompt.parse_input('command1')
    assert_instance_of(CliBuilder::Parse::Result, result)
  end
end
