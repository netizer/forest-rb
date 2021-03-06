# require "rubygems"
# require "bundler/setup"
require "byebug"

class Forest
  attr_accessor :dependencies
  # options: dependencies, file
  def initialize(options)
    @options = options
    @dependencies = @options[:dependencies]
    dependencies.set_global_options(@options)
  end

  def load(path)
    @options[:file] = path
    dependencies.set_global_options(@options)
  end

  def run(options = {})
    @options.merge!(options)
    dependencies.set_global_options(@options)
    dependencies.eval_file_with_optional_frontend(@options[:file])
  end

  def run_with_wrapper(wrapper)
    dependencies.eval_file_with_wrapper(@options[:file], wrapper)
  end

  def eval_file_with_optional_frontend(file)
    dependencies.eval_file_with_optional_frontend(file)
  end

  def command(options = {})
    @options = @options.merge(options)
    dependencies.set_global_options(@options)
    dependencies.run_command
  end
end
