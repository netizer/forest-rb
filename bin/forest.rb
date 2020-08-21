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
require File.join(dir, "lib", "forest", "dependencies", "state")
require File.join(dir, "lib", "forest", "dependencies", "stages")
require File.join(dir, "lib", "forest", "dependencies", "default")

require 'groundcover'
require 'lamb'

class DefaultDependencies < Forest::Dependencies
  include Forest::Interpreter
  include Forest::Testing
  include Forest::CGS
  include Forest::LN
  include Forest::Runner
  include Forest::Data
  include Forest::Loops
  include Forest::State
  include Forest::Stages
  include Forest::Default
  include Groundcover
  include Lamb
end

command_parts = ARGV
dependencies = DefaultDependencies.new
dir = Dir.getwd

forest = Forest.new(
  dependencies: dependencies,
  dir: dir,
  permissions: {
    macro_stage: ["context", "private", "format_call", "testing.reversed_context", "stages.with_stage"],
    runtime_stage_test: ["integer", "or", "ip", "envvar", "merge", "stages.with_stage"],
    runtime_stage_run: ["integer", "or", "ip", "envvar", "merge", "cgs.set", "cgs.set_value", "cgs.get", "stages.with_stage", "cgs.context", "data.hash_get", "testing.return_1", "testing.assert", "ln.later", "ln.now_with_args", "cgs.last"],
    stageless: ["stages.runtime_stage_run", "runner.application", "cgs.context", "data.array", "ln.later", "runner.include_task_environment", "runner.load_library", "data.array_get", "data.hash_get", "ln.now", "loops.each_key_value_by_name", "runner.explode_args_selectively", "runner.resolve_dependency", "runner.print", "ccp.with_permissions", "runner.run_from_file", "runner.print_character", "testing.assert", "testing.join", "cgs.last", "ln.now_with_args", "testing.log", "testing.logs", "state.set", "state.get", "state.get_all", "stages.with_stage"]
  }
)

forest.command(dir: dir, command_parts: command_parts)
