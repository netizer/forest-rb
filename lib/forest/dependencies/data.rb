class Forest
  module Data
    def data__forest_array_get(block)
      id = block[:children][0][:children][0][:command]
      value = evaluate(block[:children][1])
      value[id.to_i]
    end
  end
end
