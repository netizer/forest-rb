class Forest
  module ForestManipulation
    def add_parent(command, nodes, pattern)
      new_node = copy_node(pattern)
      new_node[:parent] = nil
      new_node[:command] = command
      new_node[:children] = nodes
      new_node[:children].each do |child|
        child[:parent] = new_node
      end
      new_node
    end

    def add_data_node(command, pattern)
      data_contents = copy_node(pattern)
      data_contents[:command] = command
      add_parent("data", [data_contents], pattern)
    end

    def add_call_wrapper(command, node, pattern)
      data_node = add_data_node(command, pattern)
      add_parent("call", [data_node, node], pattern)
    end

    def replace_node(node, new_node)
      new_node[:parent] = node[:parent]
      node.replace(new_node)
    end

    def add_get_branch(name, base_node)
      name_parts = name.split('.')
      first_part = name_parts[0]
      remaining_parts = name_parts[1..-1].reverse
      get_node_value_data = add_data_node(first_part, base_node)
      current_node = add_call_wrapper("cgs.get", get_node_value_data, base_node)
      remaining_parts.each do |part|
        get_node_data = add_data_node(part, base_node)
        block = add_parent("block", [get_node_data, current_node], base_node)
        hash_get_node = add_call_wrapper("data.hash_get", block, base_node)
        current_node = hash_get_node
      end
      current_node
    end
  end
end
