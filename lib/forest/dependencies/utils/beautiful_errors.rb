class Forest
  module BeautifulErrors
    def raise_forest_code_error(node, message)
      puts
      puts bold("Forest Error")
      puts "Message: #{message}"
      if interpreter_stack_trace
        puts "Backtrace:"
        puts stack_trace_text(interpreter_stack_trace.reverse)
        extension = interpreter_stack_trace.last[:file].split('.').last
        if extension != 'forest'
          interpreter_data = languages[extension]
          interpreter = interpreter_data ? interpreter_data[:name] : extension
          puts "Original code (#{interpreter}):"
          puts file_content(interpreter_stack_trace.last)
        end
      end
      puts "Forest code (line numbers are from the original file, indentation reduced for clarity):"
      puts context_text(node)
      raise "Forest application stopped with a code error."
    end

    def raise_general_error(message)
      puts bold("Forest Error")
      puts message
      raise "Forest application stopped with a general error."
    end

    # UTILS

    def file_content(node)
      lines = File.readlines(node[:file])
      line_id = node[:line] - 1
      from_line = line_id - 2
      to_line = line_id + 3
      delta = to_line.to_s.length - from_line.to_s.length
      id = 0
      result = lines[from_line..to_line].map do |line|
        line_number = from_line + id + 1
        id += 1
        justed_line_nr = line_number.to_s.rjust(delta, ' ')
        if node[:line] == line_number
          "=> #{justed_line_nr}: #{line.rstrip}"
        else
          "   #{justed_line_nr}: #{line.rstrip}"
        end
      end
      bold("#{node[:file]}:#{node[:line]}:#{node[:row]}") +
      "\n" +
      result.join("\n")
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
        result << "  #{frame[:file]}:#{frame[:line]}:#{frame[:row]} (#{command_name(frame)})"
      end
      result[0] = bold(result[0])
      result.join(" called from: \n")
    end

    def frames_without_permissions(action, ccp)
      return [] unless ccp

      result = []
      ccp.each do |item|
        result << item unless item[:permissions].include? action
      end
      result
    end

    def command_name(frame)
      if frame[:command] == "call"
        command_name = frame[:children].first[:children].first[:command]
        "#{frame[:command]}/#{command_name}"
      else
        frame[:command]
      end
    end

    # MESSAGES

    def unknown_command_error_message(command, full_command, app_file)
      "Unknown action '#{bold(command)}'.\n" +
      "A command: '#{full_command}' was called but I can't resolve it to anything I know.\n" +
      "Possible causes:\n" +
      " * Maybe the name '#{command}' was misspelled?\n" +
      " * Or maybe the action '#{command}' is not implemented in the 'tasks' section of the '#{bold(app_file)}' file (the app.* file from the current directory)?"
    end

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
      "Possible causes:\n" +
      " * Maybe you are in the wrong directory?"
    end

    def unknown_keyword_error_message(keyword)
      "Unknown keyword: '#{keyword}'.\n" +
      "Possible causes:\n" +
      " * Maybe '#{keyword}' was used in a groundcover file that was compiled " +
      "to forest, but it is not defined in the groundcover template file?\n" +
      " * Maybe '#{keyword} is defined in the groundvover template " +
      "but its children have different structure than the template expects."
    end

    def no_method_error_message(function_name, method_name)
      namespaces = method_name.split('__')
      module_name = namespaces.length > 1 && namespaces.first
      namespace_part = module_name ? "in the '#{module_name}'" : "in some"
      "Unknown forest action: '#{bold(function_name)}'.\n" +
      "Possible causes:\n" +
      " * Maybe a typo?\n" +
      " * Maybe try to create the method '#{method_name}' #{namespace_part} capability module.\n" +
      " * If the method exists, then maybe its module is not included in the dependencies class passed to Forest.new"
    end

    def not_permitted_method_error_message(command)
      "Not permitted keyword: #{bold(command)}.\n" +
      "This keyword is defined but is not listed under permissions " +
      "key for any execution stage in the call to Forest interpretter. " +
      "Possible causes:\n" +
      " * Maybe a typo?\n" +
      " * Maybe try to include '#{command}' in the list " +
      " of permitted keywords for an adequate stage of execution (e.g. runtime_stage_run)"
    end

    def permissions_error_message(action, ccp, node)
      frames = frames_without_permissions(action, ccp)

      "The node doesn't have permissions to call '#{bold(action)}'.\n" +
      "Action '#{action}' is defined, but to allow forest to call it, " +
      "all calls to '#{bold("ccp.with_permissions")}' up the backtrace have to " +
      "specify this action.\n" +
      "Possible causes:\n" +
      if frames.length == 0
        " * You do not have any call to 'ccp.with_permissions' in your code. " +
        "You can wrap your code with the call to 'ccp.with_permissions' " +
        "that sets permissions including '#{action}'."
      elsif frames.length == 1
        " * Action '#{action}' is missing from the following call " +
        "to 'ccp.with_permissions':\n" +
        file_content(frames.first[:node])
      else
        " * Action '#{action}' is missing from the following calls " +
        "to 'ccp.with_permissions':\n" +
        frames.map do |frame|
          "   #{frame[:file]}:#{frame[:line]}:#{frame[:row]}\n" +
          file_content(frame[:node])
        end.join("\n")
      end + "\n" +
      "Note:\n" +
      "Have in mind, that actions are rarely passed directly " +
      "to 'ccp.with_permissions'. " +
      "There are predefined lists (usually defined in app.gc) " +
      "that are specific to a particular use case."
    end

    def too_broad_permissions_error_message(too_broad, previous_frame)
      "The calls to 'forest.with_permissions' can only narrow down " +
      "permissions, one call tried to extend them. " +
      "The following permissions are included " +
      "but were not included in the previous (in the backtrace) call " +
      "to 'forest.with_permissions': #{too_broad.map{|el| bold(el)}.join(', ')}.\n" +
      "Possible causes:\n" +
      " * You might need to make sure that the list of permissions " +
      "in the following code contains the ones mentioned above:\n" +
      file_content(previous_frame[:node]) +
      " * One of the mentioned permissions might be misspelled"
    end

    def assert_error_message(data1, data2)
      "Assert error.\n" +
      "The following 2 data sets are expected to be identical:\n" +
      "The first:\n" +
      "#{data1.inspect}\n" +
      "The second:\n" +
      "#{data2.inspect}\n"
    end
  end
end
