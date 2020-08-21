class Forest
  module Testing
    attr_accessor :testing_logs

    def testing__forest_assert(block)
      data = evaluate(block)
      if data[0] == data[1]
        { result: true }
      else
        raise_forest_code_error(block[:parent], assert_error_message(data[0], data[1]))
      end
    end

    def testing__forest_join(block)
      data = evaluate(block)
      data.join
    end

    def testing__forest_log(block)
      data = evaluate(block)
      @testing_logs ||= []
      @testing_logs << data.first
    end

    def testing__forest_logs(_block)
      testing_logs.join
    end

    def add_text(node, text)
      node[:children][0][:command] =
        node[:children][0][:command] +
        ", #{text}"
      node
    end

    # macro-stage: changes order of elements in the context
    # runtime-stage: just clutches permissions
    # reverts x = ... statements and then asserts x outside of stages
    def testing__forest_reversed_context(node)
      parent = node[:parent]
      parent[:command] = "call"

      data_node = copy_node(node)
      data_node[:command] = "data"
      data_node_contents = copy_node(node)
      data_node_contents[:command] = "cgs.context"
      data_node_contents[:parent] = data_node
      data_node[:children] = [ data_node_contents ]
      data_node[:parent] = node

      parent[:children] = [data_node, node]
      parent[:children].each do |child|
        child[:parent] = parent
      end
      node[:command] = "block"
      new_nodes = node[:children].reverse
      node[:children] = new_nodes
      new_nodes.each do |child|
        child[:parent] = node
      end
    end

    def testing__forest_return_1(_node)
      "1"
    end
  end
end
