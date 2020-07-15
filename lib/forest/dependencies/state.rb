class Forest
  module State
    attr_accessor :state_hash

    def state__forest_set(node)
      key_part = node[:children][0]
      value_part = node[:children][1]
      # We assume that the first node here is 'data'
      # TODO: check that and throw error if it's not true
      value = evaluate(value_part)
      name = key_part[:children][0][:command]
      parts = name.strip.split(".")
      @state_hash ||= {}
      hash = @state_hash
      parts[0..-2].each do |part|
        hash[part] ||= {}
        hash = hash[part]
      end
      hash[parts[-1]] = value
    end

    def state__forest_get(node)
      # We assume that the first node here is 'data'
      # TODO: check that and throw error if it's not true
      name = node[:children][0][:command]
      parts = name.strip.split(".")
      hash = @state_hash
      parts[0..-2].each do |part|
        hash[part] ||= {}
        hash = hash[part]
      end
      hash[parts[-1]]
    end

    def state__forest_get_all(node)
      @state_hash
    end
  end
end
