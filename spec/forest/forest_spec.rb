require "spec_helper"
require "forest"
require "dependencies"
require "forest/dependencies/core"
require "forest/dependencies/interpreter"
require "forest/dependencies/thc"
require "forest/dependencies/testing"

class Forest
  class MinimalDependencies < Dependencies
    include Forest::Interpreter
    include Forest::Testing
  end
end

describe Forest do
  it "works as expected with keywords + assert function" do
    forest = Forest.new(
      file: "forest/test/forest/assert.forest",
      dependencies: Forest::MinimalDependencies.new
    )
    result = forest.run

    expect(result).to eq({ result: true })
  end

  it "works as expected with keywords + assert + join function" do
    forest = Forest.new(
      file: "forest/test/forest/join.forest",
      dependencies: Forest::MinimalDependencies.new
    )
    result = forest.run

    expect(result).to eq({ result: true })
  end
end
