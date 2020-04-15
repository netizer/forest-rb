require "spec_helper"
require "forest"
require "dependencies"
require "forest/dependencies/core"
require "forest/dependencies/interpreter"
require "forest/dependencies/thc"
require "forest/dependencies/testing"

class Forest
  class AllDependencies < Dependencies
    include Forest::Core
    include Forest::Interpreter
    include Forest::THC
    include Forest::Testing
  end
end

describe Forest do
  it "parses a simple forest file" do
    forest = Forest.new(
      file: "forest/test/forest/simple.forest",
      dependencies: Forest::AllDependencies.new
    )
    result = forest.run

    expect(result).to eq({ result: true })
  end
end
