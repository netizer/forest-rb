require "spec_helper"
require "forest_interface"
require "dependencies"
require "forest/dependencies/interpreter"
require "forest/dependencies/testing"
require "forest/dependencies/cgs"
require "forest/dependencies/ln"
require "forest/dependencies/runner"
require "forest/dependencies/data"
require "forest/dependencies/loops"
require "forest/dependencies/state"
require "forest/dependencies/stages"
require "forest/dependencies/default"

require "groundcover"
require "lamb"

class TestDependencies < Forest::Dependencies
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


describe Forest do
  describe 'usage from the command line' do
    let(:expected) do
      {
        "development" => {
          "adapter" => "postgresql",
          "pool" => 6,
          "url" => "http://data",
          "database" => "development_database"
        },
        "production" => {
          "adapter" => "postgresql",
          "pool" => 6,
          "url" => "http://data",
          "database" => "production_database",
          "username" => "username",
          "password" => "password"
        }
      }
    end

    let(:env_vars) do
      {
        "POOL" => "6",
        "DATABASE_URL" => "http://data",
        "DATABASE_PASSWORD" => "password"
      }
    end

    it 'processes a lamb file' do
      forest = ForestInterface.new(
        dependencies: TestDependencies.new,
        env: env_vars,
        permissions: {
          macro_stage: ["context", "private", "format_call", "get", "testing.reversed_context", "stages.skip"],
          runtime_stage_run: ["integer", "or", "url", "envvar", "merge", "stages.type_stage", "cgs.set", "cgs.set_value", "cgs.get", "cgs.context", "stages.skip", "cgs.last", "data.hash_get"],
          stageless: ["stages.with_stages"]
        },
        core_lib_path: "../core-lib-forest"
      )
      forest.load("spec/fixtures/example_lamb_code/config.lamb")
      data = forest.run(flow: "run")
      expect(data).to eq(expected)
    end
  end
end
