class Forest
  module ForestTraversal
    def print_node(node)
      puts "#{node[:file]}:#{node[:line]}" if node[:file]
      puts node_context_to_lines(node).join("\n")
    end

    def node_context_to_lines(node)
      @print_node_loop_control = []
      context = node_context(node)
      delta = context.last[:line].to_s.length - context.first[:line].to_s.length
      lines = []
      context.map do |line|
        justed_line_nr = line[:line].to_s.rjust(delta, ' ')
        command = line[:command]
        if command == "stages.skip"
          command += " [#{line[:disengaged_command]}]"
        end
        lines << "#{justed_line_nr}: #{line[:indent]}#{command}"
      end
      lines[0] = "=> #{lines[0]}"
      lines[1..-1].each_with_index {|line, id| lines[id + 1] = "   #{line}" }
      lines
    end

    def node_context(node, indent = "", result = [])
      if @print_node_loop_control.include?(node)
        node[:children] = []
        node[:command] = node[:command] + " LOOP"
        return node
      end
      @print_node_loop_control << node
      result << node.merge(indent: indent)
      return result unless node[:children]

      indent = indent + "  "
      node[:children].each do |child|
        node_context(child, indent, result)
      end
      result
    end
  end
end
