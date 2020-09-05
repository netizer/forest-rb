require_relative 'forest/dependencies/utils/beautiful_errors'
require_relative 'forest/dependencies/utils/forest_manipulation'

class Forest
  class Dependencies
    include BeautifulErrors
    include ForestManipulation

    def initialize
    end
  end
end
