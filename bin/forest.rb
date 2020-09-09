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

env_index = ARGV.index("--env")
env_string = env_index && ARGV[env_index + 1]
env = env_string ? env_string.split(';').map { |s| s.split('=') }.to_h : ENV

forest = Forest.new(
  dependencies: dependencies,
  dir: dir,
  permissions: {
    macro_stage: ["context", "private", "format_call", "get", "testing.reversed_context"],
    runtime_stage_test: ["integer", "or", "url", "envvar", "merge"],
    runtime_stage_run: ["integer", "or", "url", "envvar", "merge", "cgs.set", "cgs.set_value", "cgs.get", "cgs.context", "stages.skip", "data.hash_get", "testing.return_1", "testing.assert", "ln.later", "ln.now", "ln.now_with_args", "cgs.last", "testing.log", "testing.logs"],
    stageless: ["stages.runtime_stage_run", "runner.application", "cgs.context", "data.array", "ln.later", "runner.include_task_environment", "runner.load_library", "data.array_get", "data.hash_get", "ln.now", "loops.each_key_value_by_name", "runner.explode_args_selectively", "runner.resolve_dependency", "runner.print", "ccp.with_permissions", "runner.run_from_file", "runner.print_character", "testing.assert", "testing.join", "cgs.last", "ln.now_with_args", "testing.log", "testing.logs", "state.set", "state.get", "state.get_all", "stages.with_stages"]
  },
  # you need to run `ln -s ~/4st/core-lib-forest forestcorelib`
  # or change the string below to the directory where
  # core-lib-forest repository is
  core_lib_path: "#{ENV['HOME']}/forestcorelib",
  env: env
)

if ARGV[0] == 'app'
  forest.command(dir: dir, command_parts: command_parts)
else
  forest.load(ARGV[0])
  result = forest.run(flow: "run")
  puts result.inspect
end
