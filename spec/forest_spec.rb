require "spec_helper"
require "forest"
require "dependencies"
require "forest/dependencies/interpreter"
require "forest/dependencies/testing"
require "forest/dependencies/cgs"
require "forest/dependencies/ln"

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

  class DependenciesWithLN < Dependencies
    include Forest::Interpreter
    include Forest::Testing
    include Forest::CGS
    include Forest::LN
  end
end

describe Forest do
  it "passes all the tests for the interpreter (call, block, data) module" do
    assert_result_true(
      "forest/",
      Forest::MinimalDependencies.new,
      [
        "assert.forest",
        "join.forest"
      ]
    )
  end

  it "passes all the tests for the CGS (context, set, get) module" do
    assert_result_true(
      "cgs/",
      Forest::DependenciesWithCGS.new,
      [
        "set_followed_by_get_same_context.forest",
        "get_uses_set_from_closer_context.forest"
      ]
    )
  end

  it "passes all the tests for the LN (later, now) module" do
    assert_result_true(
      "ln/",
      Forest::DependenciesWithLN.new,
      [
        "running_code_later.forest",
        "use_definition_scope.forest",
        "function_with_arguments.forest",
        "arguments_have_priority_over_defintion_context.forest",
        "function_argument_is_called_in_its_definition_context.forest"
      ]
    )
  end
end
