module Helpers
  FOREST_TESTS_DIRECTORY = "forest/test/"

  def assert_result_true(directory, dependencies, files)
    directory = "#{FOREST_TESTS_DIRECTORY}#{directory}"
    files.each do |file|
      forest = Forest.new(
        file: "#{directory}#{file}",
        dependencies: dependencies
      )
      result = forest.run

      expect(result).to eq({ result: true })
    end
  end
end
