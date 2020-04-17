require "spec_helper"
require "forest"
require "dependencies"
require "forest/dependencies/interpreter"
require "forest/dependencies/testing"
require "forest/dependencies/cgs"

class Forest
  class MinimalDependencies < Dependencies
    include Forest::Interpreter
    include Forest::Testing
  end

  class DependenciesWithCGS < Dependencies
    include Forest::Interpreter
    include Forest::Testing
    include Forest::CGS
  end
end

FOREST_TESTS_DIRECTORY = "forest/test/"

describe Forest do
  it "passes all the tests for the interpreter module" do
    directory = "#{FOREST_TESTS_DIRECTORY}forest/"
    files = [
      "assert.forest",
      "join.forest"
    ]
    files.each do |file|
      forest = Forest.new(
        file: "#{directory}#{file}",
        dependencies: Forest::MinimalDependencies.new
      )
      result = forest.run

      expect(result).to eq({ result: true })
    end
  end

  it "passes all the tests for the CGS (context, set, get) module" do
    directory = "#{FOREST_TESTS_DIRECTORY}cgs/"
    files = [
      "set_followed_by_get_same_context.forest"
    ]
    files.each do |file|
      forest = Forest.new(
        file: "#{directory}#{file}",
        dependencies: Forest::DependenciesWithCGS.new
      )
      result = forest.run

      expect(result).to eq({ result: true })
    end
  end
end
