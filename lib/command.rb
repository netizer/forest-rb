#!/usr/bin/env ruby

dir = __dir__

require File.join(dir, "forest")
require File.join(dir, "dependencies")
require File.join(dir, "forest/dependencies/interpreter")
require File.join(dir, "forest/dependencies/testing")
require File.join(dir, "forest/dependencies/cgs")
require File.join(dir, "forest/dependencies/ln")
require File.join(dir, "forest/dependencies/runner")

class DefaultDependencies
  include Forest::Interpreter
  include Forest::Testing
  include Forest::CGS
  include Forest::LN
end

command_parts = ARGV
dependencies = DefaultDependencies.new
dir = Dir.getwd

forest = Forest.new(
  dependencies: dependencies,
  dir: dir
)

result = forest.command(dir: dir, command_parts: command_parts)

puts result
