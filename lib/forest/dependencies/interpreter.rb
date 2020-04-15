class Forest
  module Interpreter
    INDENTATION_BASE = 2
    KEYWORD_PREFIX = 'forest_keyword_'
    FUNCTION_PREFIX = 'forest_'

    def eval_file(file)
      files_content = read(file)
      tree = parse(files_content)
      evaluate(tree)
    end

    private

    def read(file)
      File.readlines(file)
    end

    def parse(lines)
      current_node = create_node(0, lines[0], nil)
      root_node = current_node
      lines[1..-1].each do |line|
        current_node = parse_line(line, current_node)
      end
      root_node
    end

    def evaluate(node)
      method_name = "#{KEYWORD_PREFIX}#{node[:command]}"
      send(method_name, node[:children])
    end

    def forest_keyword_call(children)
      block = evaluate(children[0])
      function_name = block[0]

      function_name_parts = function_name.strip.split('.')
      method_suffix = "#{FUNCTION_PREFIX}#{function_name_parts.last}"

      method_name = (function_name_parts[0..-2] + [method_suffix]).join('__')
      public_send(method_name, block[1])
    end

    def forest_keyword_block(children)
      children.map do |child|
        evaluate(child)
      end
    end

    def forest_keyword_data(children)
      children.map do |child|
        child[:contents]
      end.join
    end

    def parse_line(line, current_node)
      indent_level, line_content = extract_indentation(line)
      ancestor_level = 1 + current_node[:indent] - indent_level
      parent_node = ancestor(current_node, ancestor_level)
      new_node = create_node(indent_level, line_content, parent_node)
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

    def create_node(indent_level, line, parent)
      {
        indent: indent_level,
        contents: line,
        parent: parent,
        children: [],
        command: line.strip
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
  end
end
