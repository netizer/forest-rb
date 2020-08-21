class Forest
  module Data
    def data__forest_array_get(block)
      id = block[:children][0][:children][0][:command]
      value = evaluate(block[:children][1])
      value[id.to_i]
    end

    def data__forest_hash_get(node)
      key = evaluate(node[:children][0])
      hash = evaluate(node[:children][1])
      hash[key]
    end

    def data__forest_array(node)
      collection = evaluate(node)
      collection.values
    end

    def data__forest_merge(node)
      hash1 = evaluate(node[:children][0])
      hash2 = evaluate(node[:children][1])
      hash1.merge(hash2)
    end
  end
end
