# require "rubygems"
require "forest"

# This file determines how Forest is used from the host language.
# It is language-specific and the interface can be
# significantly different in different environments.

class ForestInterface
  def initialize(options)
    @forest_init_options = options
    @forest_run_options = {}
    # TODO: move file wrapper to Forest
    @file_wrapper = options[:file_wrapper]
  end

  def run(options = {})
    @run_options = options
    @forest = Forest.new(@forest_init_options.merge(@run_options))
    @forest.eval_file_with_optional_frontend(@forest_init_options[:file])
  end

  def cap(name)
  end

  def load(path)
    @forest_init_options[:file] = path
  end

  def gear(capabilities)
  end
end
