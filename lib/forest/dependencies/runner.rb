require 'fileutils'

class Forest
  module Runner
    INTERPRETERS = {
      'gc' => {
        name: 'Groundcover',
        forest_command: 'groundcover.parse_text_to_forest',
        method: :groundcover__forest_parse_to_forest
      },
      'lamb' => {
        name: 'Lamb',
        forest_command: 'lamb.parse_text_to_forest',
        method: :lamb__forest_parse_to_forest
      }
    }.freeze

    attr_accessor :runner_application
    attr_accessor :runner_command_parts

    def runner__forest_include_task_environment(children)
      cgs_internal_set('command_parts', @runner_command_parts)
      cgs_internal_set('dependencies', @runner_application['dependencies'])
    end

    def runner__forest_application(node)
      @runner_application = evaluate(node)
    end

    def runner__forest_print(node)
      puts evaluate(node)
    end

    def runner__forest_print_character(node)
      putc evaluate(node)
    end

    def eval_file_with_optional_frontend(file, glob = nil)
      tree = parse_file_with_optional_frontend(file, glob)
      evaluate(tree)
    end

    def parse_file_with_optional_frontend(file, glob = nil)
      raise_general_error(missing_app_file_error_message(glob)) if file.nil?

      extension = file.split(".").last
      if extension == 'forest'
        parse_file(file)
      else
        parse_file_with_frontend(file, extension)
      end
    end

    def eval_file_with_frontend(file, extension)
      forest = parse_file_with_frontend(file, extension)
      evaluate(forest)
    end

    def parse_file_with_frontend(file, extension)
      interpreter = INTERPRETERS[extension][:method]
      @interpreter_file = file
      public_send(interpreter, file)
    end

    def run_command(options)
      @options = options
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
      node = @runner_application['tasks'][command]
      unless node
        full_command = "forest app #{command_parts.join(' ')}"
        raise_general_error(unknown_command_error_message(command, full_command, @interpreter_file))
      end
      call_code_with_context(node)
    end

    def runner__forest_explode_args_selectively(node)
      passed_args = cgs_internal_get('args')
      node[:children].each do |child|
        old_name = evaluate(child[:children][0])
        old_name = old_name.to_i if old_name.to_i.to_s == old_name
        new_name = evaluate(child[:children][1])
        new_name = new_name.to_i if new_name.to_i.to_s == new_name
        cgs_internal_set(new_name, passed_args[old_name])
      end
    end

    def runner__forest_run_from_file(node)
      file = node[:children][0][:command]
      eval_file_with_optional_frontend(file)
    end
  end
end
