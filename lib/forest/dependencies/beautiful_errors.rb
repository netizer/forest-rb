class Forest
  module BeautifulErrors
    def rise_forest_code_error(node, message)
      puts bold("Forest Error")
      puts "Message: #{message}"
      puts "Backtrace:"
      puts stack_trace_text(interpreter_stack_trace)
      unless interpreter_stack_trace.first.to_s[/\.forest\Z/]
        puts "Original code:"
        puts file_content(interpreter_stack_trace.first)
      end
      puts "Forest code (line numbers are from the original file, indentation reduced for clarity):"
      puts context_text(node)
      exit 1
    end

    def file_content(frame)
      lines = File.readlines(frame[:file])
      line_id = frame[:line] - 1
      from_line = line_id - 2
      to_line = line_id + 3
      delta = to_line.to_s.length - from_line.to_s.length
      id = 0
      lines[from_line..to_line].map do |line|
        line_number = from_line + id + 1
        id += 1
        justed_line_nr = line_number.to_s.rjust(delta, ' ')
        if frame[:line] == line_number
          "=> #{justed_line_nr}: #{line}"
        else
          "   #{justed_line_nr}: #{line}"
        end
      end
    end

    def context_text(node)
      lines = node_context_to_lines(node)[0..5]
      lines.join("\n")
    end

    def bold(text)
      "\033[1m#{text}\033[0m"
    end

    def stack_trace_text(stack)
      result = []
      stack.each do |frame|
        result << "  #{frame[:file]}:#{frame[:line]}:#{frame[:row]} (#{frame[:command]})"
      end
      result[0] = bold(result[0])
      result.join(" called from: \n")
    end

    def print_general_error(message)
      puts "FOREST ERROR:"
      puts message
      exit 1
    end

    # MESSAGES

    def unknown_name_error_message(name)
      "The action 'get' was called with the argument '#{name}' but this name is not available in the scope.\n" +
      "Possible causes:\n" +
      " * Maybe you misspelled '#{name}'?"
    end

    def missing_app_file_error_message(glob)
      parts = glob.split('/')
      file = parts.last
      dir = parts[0..-2].join('/')
      "File doesn't exist: #{glob}\n" +
      "Possible causes:\n"
      " * Maybe you are in the wrong directory?"
    end

    def unknown_keyword_error_message(keyword)
      "Unknown keyword: '#{keyword}'.\n" +
      "Possible causes:\n" +
      " * Maybe '#{keyword}' was used in a groundcover file that was comiled to forest, but it is not defined in the groundcover template file?\n" +
      " * Maybe '#{keyword} is defined in the groundvover template but its children have different structure than the template expects."
    end

    def no_method_error_message(function_name, method_name)
      namespaces = method_name.split('__')
      module_name = namespaces.length > 1 && namespaces.first
      namespace_part = module_name ? "in the '#{module_name}'" : "in some"
      "Unknown forest action: '#{bold(function_name)}'.\n" +
      "Possible reasones:\n" +
      " * Maybe try to create the method '#{method_name}' #{namespace_part} capability module."
    end
  end
end
