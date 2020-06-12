# require "rubygems"
# require "bundler/setup"
require "byebug"

class Forest
  attr_accessor :dependencies
  # options: dependencies, file
  def initialize(options)
    @init_options = options
    @dependencies = @init_options[:dependencies]
  end

  def run(options = {})
    @run_options = options
    dependencies.eval_file(@init_options[:file])
  end

  def command(options = {})
    @run_options = options
    dependencies.run_command(
      init_options: @init_options,
      run_options: @run_options
    )
  end
end
