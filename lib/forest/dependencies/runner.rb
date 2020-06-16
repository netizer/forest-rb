require 'fileutils'

class Forest
  module Runner
    INTERPRETERS = {
      'gc' => {
        forest_command: 'groundcover.parse_text_to_forest',
        method: :groundcover__forest_parse_to_forest
      }
    }.freeze

    attr_accessor :runner_application
    attr_accessor :runner_command_parts

    def runner__forest_application(node)
      @runner_application = evaluate(node)
    end

    def runner__forest_print(node)
      puts evaluate(node)
    end

    def eval_file_with_optional_frontend(file, glob)
      print_general_error(missing_app_file_error_message(glob)) if file.nil?

      extension = file.split(".").last
      if extension == 'forest'
        eval_file(file)
      else
        eval_file_with_frontend(file, extension)
      end
    end

    # TODO: not used at the moment
    def runner__forest_inline_language(children)
      extension = children[0][:children][0]
      data = children[1][:children]
      interpreter = INTERPRETERS[extension][:forest_command]
      tree = public_send(interpreter, data)
      parent = children[0][:parent]
      add_meta(tree, parent, parent[:line], parent[:row] + 2)
    end

    def eval_file_with_frontend(file, extension)
      interpreter = INTERPRETERS[extension][:method]
      @interpreter_file = file
      forest = public_send(interpreter, file)
      evaluate(forest)
    end

    # TODO: not used at the moment
    def add_meta(node, parent = nil, line_shift = 0, row_shift = 0)
      node[:parent] = parent
      node[:line] = parent[:line] + line_shift
      node[:row] = parent[:row] + row_shift
      node[:children].each do |child|
        add_meta(child, node, line_shift, row_shift)
      end
      node
    end

    def run_command(options)
      command_parts = options[:run_options][:command_parts]
      command = command_parts.shift
      send("command_#{command}", command_parts, options)
    end

    def command_app(command_parts, options)
      @runner_command_parts = command_parts
      command = command_parts[0]
      glob = "#{options[:run_options][:dir]}/app.*"
      matching_files = Dir.glob(glob)
      app_file = matching_files.first
      eval_file_with_optional_frontend(app_file, glob)
      call_code_with_context(@runner_application['tasks'][command])
    end

    def runner__forest_resolve(children)
      dependency = evaluate(children[0])
      raise "Not implemented yet" if dependency[:data] != 'local'

      FileUtils.mkdir_p("vendor")
      dir_name = dependency.split('/').last
      FileUtils.copy_entry dependency[:path], "vendor/#{dir_name}"
    end
  end
end
