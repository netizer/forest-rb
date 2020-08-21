require_relative 'ccp'

class Forest
  module Interpreter
    include Forest::CCP

    INDENTATION_BASE = 2
    KEYWORD_PREFIX = 'forest_keyword_'
    FUNCTION_PREFIX = 'forest_'

    attr_accessor :interpreter_file
    attr_accessor :interpreter_stack_trace

    def interpreter_add_stack_trace(options = {})
      @interpreter_stack_trace ||= []
      @interpreter_stack_trace << options
    end

    def remove_stack_trace
      @interpreter_stack_trace.pop
    end

    def eval_file(file)
      tree = parse_file(file)
      evaluate(tree)
    end

    def method_name_of(function_name)
      function_name = "default.#{function_name}" unless function_name["."]
      function_name_parts = function_name.split('.')

      method_suffix = "#{FUNCTION_PREFIX}#{function_name_parts.last}"
      namespace_part = function_name_parts[0..-2]

      method_name = (namespace_part + [method_suffix]).join('__')
    end

    def forest_keyword_call(node)
      children = node[:children]
      ensure_equal(children[0][:command], 'data', children[0])

      function_name = children[0][:children][0][:command]
      body = children[1]

      method_name = method_name_of(function_name)
      interpreter_add_stack_trace(node)
      unless public_methods.include?(method_name.to_sym)
        # TODO: most likely we don't need it as this logic was moved
        # to stages.check_function_calls
        raise_forest_code_error(node, no_method_error_message(function_name, method_name))
      end
      ccp_ensure_permissions(function_name, node)
      result = public_send(method_name, body)
      remove_stack_trace
      result
    end

    def forest_keyword_block(node)
      children = node[:children]
      children.map do |child|
        evaluate(child)
      end
    end

    def forest_keyword_data(node)
      children = node[:children]
      children.map do |child|
        child[:command]
      end.join
    end

    private

    def parse_file(file)
      @interpreter_file = file
      files_content = read(file)
      parse(files_content)
    end

    def read(file)
      File.readlines(file)
    end

    def parse(lines)
      current_node = create_node(0, lines[0], nil, line: 1, row: 1)
      root_node = current_node
      lines[1..-1].each_with_index do |line, id|
        current_node = parse_line(line, current_node, id + 2)
      end
      root_node
    end

    def evaluate(node)
      method_name = "#{KEYWORD_PREFIX}#{node[:command]}"
      unless methods.include?(method_name.to_sym)
        raise_forest_code_error(node, unknown_keyword_error_message(node[:command]))
      end
      send(method_name, node)
    end

    def parse_line(line, current_node, line_nr)
      indent_level, line_content = extract_indentation(line)
      ancestor_level = 1 + current_node[:indent] - indent_level
      parent_node = ancestor(current_node, ancestor_level)
      new_node = create_node(indent_level, line_content, parent_node, line: line_nr, row: (indent_level + 1) * 2 + 1)
      parent_node[:children] << new_node
      new_node
    end

    def ancestor(parent_node, ancestor_level)
      ancestor_node = parent_node
      ancestor_level.times do
        ancestor_node = ancestor_node[:parent]
      end
      ancestor_node
    end

    def create_node(indent_level, line, parent, options = {})
      command = line.strip
      raise "Empty lines in source files are not supported" if command == ""

      {
        indent: indent_level,
        parent: parent,
        children: [],
        command: command,
        child_id: parent ? parent[:children].length : 0,
        line: options[:line],
        row: options[:row],
        file: @interpreter_file
      }
    end

    def extract_indentation(line)
      index = 0
      line.each_char do |char|
        if char == ' '
          index += 1
        else
          return [index / INDENTATION_BASE, line[index..-1]]
        end
      end
    end

    def ensure_equal(arg1, arg2, node)
      return if arg1 == arg2

      path = ["#{node[:command]}(#{node[:child_id]})"]
      while node = node[:parent]
        path.push("#{node[:command]}(#{node[:child_id]})")
      end
      path_string = path.reverse.join('.')
      raise "ASSERTION ERROR: #{arg1} <> #{arg2}; path: #{path_string}"
    end

    # Debugger
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
