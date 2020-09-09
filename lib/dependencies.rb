require_relative 'forest/dependencies/utils/language_register'
require_relative 'forest/dependencies/utils/forest_traversal'
require_relative 'forest/dependencies/utils/forest_manipulation'
require_relative 'forest/dependencies/utils/beautiful_errors'

class Forest
  class Dependencies
    extend LanguageRegister
    include ForestTraversal
    include ForestManipulation
    include BeautifulErrors

    def languages
      self.class.languages
    end
  end
end
