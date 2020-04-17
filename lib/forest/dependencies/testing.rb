class Forest
  module Testing
    def testing__forest_assert(block)
      data = evaluate(block)
      if data[0] == data[1]
        { result: true }
      else
        { result: false }
      end
    end

    def testing__forest_join(block)
      data = evaluate(block)
      data.join
    end
  end
end
