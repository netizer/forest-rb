class Forest
  module Testing
    def testing__forest_assert(children)
      if children[0] == children[1]
        { result: true }
      else
        { result: false }
      end
    end

    def testing__forest_join(children)
      children.join
    end
  end
end
