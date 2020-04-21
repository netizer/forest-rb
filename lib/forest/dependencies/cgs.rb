class Forest
  module CGS
    attr_accessor :cgs_data
    attr_accessor :cgs_name_to_data_id_map

    def cgs__forest_context(block)
      setup_data
      new_names = []
      data = evaluate(block)
      cleanup_data(new_names)
      data.last
    end

    def cgs__forest_get(block)
      data = evaluate(block)
      name = data[0].strip
      id = @cgs_name_to_data_id_map[name].last
      @cgs_data[id]
    end

    def cgs__forest_set(block)
      data = evaluate(block)
      name = data[0].strip
      value = data[1]
      @cgs_name_to_data_id_map[name] ||= []
      id = @cgs_data.length
      @cgs_data.push(value)
      @cgs_name_to_data_id_map[name].push(id)
    end

    private

    def setup_data
      @cgs_data ||= []
      @cgs_name_to_data_id_map ||= {}
    end

    def cleanup_data(names)
      names.each do |name|
        if @cgs_name_to_data_id_map[name].length == 1
          id = @cgs_name_to_data_id_map[name].last
          @cgs_data[id] = nil
          @cgs_name_to_data_id_map.delete(name)
        else
          @cgs_name_to_data_id_map[name].pop
        end
      end
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
