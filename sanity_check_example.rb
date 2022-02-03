require 'cli-builder.rb'

prompt = CliBuilder::Prompt.new
prompt.register_command(
  :command1,
  '[FOOBAR foobar] [QUXBAZ quxbaz]', 
  command_help: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Elit sed vulputate mi sit amet. Semper risus in hendrerit gravida rutrum quisque non tellus orci. Integer enim neque volutpat ac. Cursus mattis molestie a iaculis at erat pellentesque adipiscing. Risus nullam eget felis eget nunc lobortis mattis aliquam faucibus. Mauris in aliquam sem fringilla ut. Erat nam at lectus urna. Bibendum arcu vitae elementum curabitur vitae nunc. Sodales neque sodales ut etiam sit amet nisl purus. Sed ullamcorper morbi tincidunt ornare massa eget egestas. Laoreet id donec ultrices tincidunt arcu. Commodo viverra maecenas accumsan lacus vel facilisis volutpat. Pellentesque sit amet porttitor eget. Cras ornare arcu dui vivamus arcu felis bibendum ut. Morbi blandit cursus risus at ultrices mi. Massa id neque aliquam vestibulum. Morbi tincidunt augue interdum velit. Ridiculus mus mauris vitae ultricies leo",
  argument_help: {
    foobar: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Cras semper auctor neque vitae tempus quam pellentesque. Aliquet nibh praesent tristique magna sit amet. Facilisis mauris sit amet massa. Volutpat diam ut venenatis tellus in. Sem viverra aliquet eget sit amet tellus cras adipiscing enim. Malesuada pellentesque elit eget gravida. Phasellus egestas tellus rutrum tellus pellentesque. Rhoncus aenean vel elit scelerisque mauris. Nullam eget felis eget nunc lobortis. Sagittis orci a scelerisque purus semper eget. Tincidunt lobortis feugiat vivamus at augue. Hac habitasse platea dictumst vestibulum rhoncus est pellentesque elit ullamcorper. Integer quis auctor elit sed vulputate mi. Purus in mollis nunc sed.",
    quxbaz: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Est lorem ipsum dolor sit amet. Habitant morbi tristique senectus et. Odio morbi quis commodo odio aenean sed adipiscing diam. Sit amet risus nullam eget felis eget. Diam maecenas ultricies mi eget mauris pharetra. Imperdiet sed euismod nisi porta lorem. Tellus elementum sagittis vitae et leo duis ut diam quam. Elementum curabitur vitae nunc sed. Posuere sollicitudin aliquam ultrices sagittis orci a. Quis eleifend quam adipiscing vitae. Accumsan in nisl nisi scelerisque eu ultrices vitae auctor. Vulputate sapien nec sagittis aliquam malesuada bibendum arcu vitae elementum. Venenatis lectus magna fringilla urna porttitor rhoncus. Diam quis enim lobortis scelerisque fermentum. Netus et malesuada fames ac turpis egestas maecenas. Lorem ipsum dolor sit amet consectetur adipiscing elit duis tristique. Risus viverra adipiscing at in tellus integer feugiat."
  }
) do |result|
end

prompt.register_command(
  :command2,
  '[FOOBAR foobar] [QUXBAZ quxbaz]', 
  command_help: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Elit sed vulputate mi sit amet. Semper risus in hendrerit gravida rutrum quisque non tellus orci. Integer enim neque volutpat ac. Cursus mattis molestie a iaculis at erat pellentesque adipiscing. Risus nullam eget felis eget nunc lobortis mattis aliquam faucibus. Mauris in aliquam sem fringilla ut. Erat nam at lectus urna. Bibendum arcu vitae elementum curabitur vitae nunc. Sodales neque sodales ut etiam sit amet nisl purus. Sed ullamcorper morbi tincidunt ornare massa eget egestas. Laoreet id donec ultrices tincidunt arcu. Commodo viverra maecenas accumsan lacus vel facilisis volutpat. Pellentesque sit amet porttitor eget. Cras ornare arcu dui vivamus arcu felis bibendum ut. Morbi blandit cursus risus at ultrices mi. Massa id neque aliquam vestibulum. Morbi tincidunt augue interdum velit. Ridiculus mus mauris vitae ultricies leo",
  argument_help: {
    foobar: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Cras semper auctor neque vitae tempus quam pellentesque. Aliquet nibh praesent tristique magna sit amet. Facilisis mauris sit amet massa. Volutpat diam ut venenatis tellus in. Sem viverra aliquet eget sit amet tellus cras adipiscing enim. Malesuada pellentesque elit eget gravida. Phasellus egestas tellus rutrum tellus pellentesque. Rhoncus aenean vel elit scelerisque mauris. Nullam eget felis eget nunc lobortis. Sagittis orci a scelerisque purus semper eget. Tincidunt lobortis feugiat vivamus at augue. Hac habitasse platea dictumst vestibulum rhoncus est pellentesque elit ullamcorper. Integer quis auctor elit sed vulputate mi. Purus in mollis nunc sed.",
    quxbaz: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Est lorem ipsum dolor sit amet. Habitant morbi tristique senectus et. Odio morbi quis commodo odio aenean sed adipiscing diam. Sit amet risus nullam eget felis eget. Diam maecenas ultricies mi eget mauris pharetra. Imperdiet sed euismod nisi porta lorem. Tellus elementum sagittis vitae et leo duis ut diam quam. Elementum curabitur vitae nunc sed. Posuere sollicitudin aliquam ultrices sagittis orci a. Quis eleifend quam adipiscing vitae. Accumsan in nisl nisi scelerisque eu ultrices vitae auctor. Vulputate sapien nec sagittis aliquam malesuada bibendum arcu vitae elementum. Venenatis lectus magna fringilla urna porttitor rhoncus. Diam quis enim lobortis scelerisque fermentum. Netus et malesuada fames ac turpis egestas maecenas. Lorem ipsum dolor sit amet consectetur adipiscing elit duis tristique. Risus viverra adipiscing at in tellus integer feugiat."
  }
) do |result|
end

prompt.register_command(
  :jommand,
  '[FOOBAR foobar] [QUXBAZ quxbaz]', 
  command_help: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Elit sed vulputate mi sit amet. Semper risus in hendrerit gravida rutrum quisque non tellus orci. Integer enim neque volutpat ac. Cursus mattis molestie a iaculis at erat pellentesque adipiscing. Risus nullam eget felis eget nunc lobortis mattis aliquam faucibus. Mauris in aliquam sem fringilla ut. Erat nam at lectus urna. Bibendum arcu vitae elementum curabitur vitae nunc. Sodales neque sodales ut etiam sit amet nisl purus. Sed ullamcorper morbi tincidunt ornare massa eget egestas. Laoreet id donec ultrices tincidunt arcu. Commodo viverra maecenas accumsan lacus vel facilisis volutpat. Pellentesque sit amet porttitor eget. Cras ornare arcu dui vivamus arcu felis bibendum ut. Morbi blandit cursus risus at ultrices mi. Massa id neque aliquam vestibulum. Morbi tincidunt augue interdum velit. Ridiculus mus mauris vitae ultricies leo",
  argument_help: {
    foobar: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Cras semper auctor neque vitae tempus quam pellentesque. Aliquet nibh praesent tristique magna sit amet. Facilisis mauris sit amet massa. Volutpat diam ut venenatis tellus in. Sem viverra aliquet eget sit amet tellus cras adipiscing enim. Malesuada pellentesque elit eget gravida. Phasellus egestas tellus rutrum tellus pellentesque. Rhoncus aenean vel elit scelerisque mauris. Nullam eget felis eget nunc lobortis. Sagittis orci a scelerisque purus semper eget. Tincidunt lobortis feugiat vivamus at augue. Hac habitasse platea dictumst vestibulum rhoncus est pellentesque elit ullamcorper. Integer quis auctor elit sed vulputate mi. Purus in mollis nunc sed.",
    quxbaz: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Est lorem ipsum dolor sit amet. Habitant morbi tristique senectus et. Odio morbi quis commodo odio aenean sed adipiscing diam. Sit amet risus nullam eget felis eget. Diam maecenas ultricies mi eget mauris pharetra. Imperdiet sed euismod nisi porta lorem. Tellus elementum sagittis vitae et leo duis ut diam quam. Elementum curabitur vitae nunc sed. Posuere sollicitudin aliquam ultrices sagittis orci a. Quis eleifend quam adipiscing vitae. Accumsan in nisl nisi scelerisque eu ultrices vitae auctor. Vulputate sapien nec sagittis aliquam malesuada bibendum arcu vitae elementum. Venenatis lectus magna fringilla urna porttitor rhoncus. Diam quis enim lobortis scelerisque fermentum. Netus et malesuada fames ac turpis egestas maecenas. Lorem ipsum dolor sit amet consectetur adipiscing elit duis tristique. Risus viverra adipiscing at in tellus integer feugiat."
  }
) do |result|
end


=begin
prompt.register_command(:command1) do |result|
  puts result.to_s
end

prompt.register_command(:command2, '[FOO_BAR foo]') do |result|
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

prompt.register_command(
  :command5,
  '<foo> <BAR bar>',
  command_help: 'test',
  argument_help: {
    foo: 'do the foo',
    bar: 'do the bar'
  }
) do |result|
end
=end

prompt.run_command('help')
