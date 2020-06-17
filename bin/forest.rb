#!/usr/bin/env ruby

require "pathname"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../../Gemfile",
  Pathname.new(__FILE__).realpath)

require "rubygems"
require "bundler/setup"

dir = File.expand_path("..", __dir__)

require File.join(dir, "lib", "forest")
require File.join(dir, "lib", "dependencies")
require File.join(dir, "lib", "forest", "dependencies", "interpreter")
require File.join(dir, "lib", "forest", "dependencies", "testing")
require File.join(dir, "lib", "forest", "dependencies", "cgs")
require File.join(dir, "lib", "forest", "dependencies", "ln")
require File.join(dir, "lib", "forest", "dependencies", "runner")
require File.join(dir, "lib", "forest", "dependencies", "data")
require File.join(dir, "lib", "forest", "dependencies", "loops")

require 'groundcover'

class DefaultDependencies < Forest::Dependencies
  include Forest::Interpreter
  include Forest::Testing
  include Forest::CGS
  include Forest::LN
  include Forest::Runner
  include Forest::Data
  include Forest::Loops
  include Groundcover
end

command_parts = ARGV
dependencies = DefaultDependencies.new
dir = Dir.getwd

forest = Forest.new(
  dependencies: dependencies,
  dir: dir
)

forest.command(dir: dir, command_parts: command_parts)
