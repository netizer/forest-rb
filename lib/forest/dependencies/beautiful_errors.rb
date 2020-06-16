class Forest
  module BeautifulErrors
    def rise_forest_code_error(node, message)
      puts "FOREST ERROR"
      puts "Message: #{message}"
      puts "Location: #{@interpreter_file}:#{node[:line]}:#{node[:row]}"
      puts "Command: #{node[:command]}"
      exit 1
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
      " * Maybe you misspelled the argument of 'get'?"
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
      " * Maybe '#{keyword}' was used in a groundcover file that was comiled to forest, but '#{keyword}' is not defined in the groundcover template file?\n" +
      " * Maybe '#{keyword} is defined in the groundvover template but its children have different structure than the template expects."
    end

    def no_method_error_message(function_name, method_name)
      "Unknown forest action: '#{function_name}'.\n" +
      "Possible reasones:\n" +
      " * It looks like you should create the method '#{method_name}' in one of the dependencies module (host environment - ruby)."
    end
  end
end
