class Forest
  module CGS
    attr_accessor :cgs_data
    attr_accessor :cgs_name_to_data_id_map
    # how many times a name was assigned in a context
    attr_accessor :cgs_context_name_counts
    attr_accessor :cgs_context_sizes

    def cgs__forest_context(block)
      setup_data
      evaluate(block)
      result = @cgs_context_name_counts.last.map do |name, count|
        [name, @cgs_data[@cgs_name_to_data_id_map[name].last]]
      end.to_h
      cleanup_data
      result
    end

    def cgs__forest_get(block)
      name = evaluate(block).strip
      cgs_internal_get(name)
    end

    def cgs_internal_get(name)
      data_ids = @cgs_name_to_data_id_map[name]
      unless data_ids
        rise_forest_code_error(block[:parent], unknown_name_error_message(name))
      end
      id = data_ids.last
      @cgs_data[id]
    end

    def cgs__forest_set(block)
      data = evaluate(block)
      key = data[0].strip
      value = data[1]
      cgs_internal_set(key, value)
      { type: :pair, key: key, value: value }
    end

    def cgs__forest_set_value(block)
      data = evaluate(block)
      cgs_internal_set(@cgs_context_sizes.last, data)
      { type: :value, value: data }
    end

    def cgs_internal_set(name, value)
      @cgs_name_to_data_id_map[name] ||= []
      id = @cgs_data.length
      @cgs_data.push(value)
      @cgs_name_to_data_id_map[name].push(id)

      @cgs_context_name_counts.last[name] ||= 0
      @cgs_context_name_counts.last[name] += 1
      @cgs_context_sizes[@cgs_context_sizes.length - 1] = @cgs_context_sizes.last + 1
    end

    def cgs__forest_last(block)
      evaluate(block).values.last
    end

    private

    def setup_data
      @cgs_data ||= []
      @cgs_name_to_data_id_map ||= {}

      @cgs_context_name_counts ||= []
      @cgs_context_name_counts << {}
      @cgs_context_sizes ||= []
      @cgs_context_sizes << 0
    end

    def cleanup_data
      @cgs_context_name_counts.last.each do |name, count|
        if @cgs_name_to_data_id_map[name].length == count
          @cgs_name_to_data_id_map[name].each do |id|
            @cgs_data[id] = nil
          end
          @cgs_name_to_data_id_map.delete(name)
        else
          count.times { @cgs_name_to_data_id_map[name].pop }
        end
        @cgs_context_name_counts.last.delete(name)
      end
      @cgs_context_name_counts.pop
      @cgs_context_sizes.pop

    end

    # exposed to other modules

    def cgs_context_snapshot
      cgs_map = @cgs_name_to_data_id_map.dup
      cgs_map.each do |key, value|
        cgs_map[key] = value.dup
      end
      {
        cgs_data: @cgs_data.dup,
        cgs_name_to_data_id_map: cgs_map
      }
    end

    def cgs_replace_context(snapshot)
      current_context = cgs_context_snapshot
      @cgs_data = snapshot[:cgs_data]
      @cgs_name_to_data_id_map = snapshot[:cgs_name_to_data_id_map]
      current_context
    end
  end
end
