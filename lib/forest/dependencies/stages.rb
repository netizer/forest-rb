class Forest
  # The module provides wrappers for:
  # - files
  # - libraries (TBD)
  # - applications (TBD)
  # For each flow there is a different file. It will be possible
  # to set this file in the library, but currently only the one
  # from core-lib-forest is used.
  module Stages
    attr_accessor :stages_flow
    attr_accessor :current_stage

    FLOWS = {
      test: {
        macro: "macro_stage", # stage: stage_variant
        type: "type_stage",
        runtime: "runtime_stage_test"
      },
      run: {
        macro: "macro_stage",
        type: "type_stage",
        runtime: "runtime_stage_run"
      }
    }
    TEMPLATES = {
      test: "flows_test.forest",
      run: "flows_run.forest"
    }

    def current_flow
      @current_flow
    end

    def current_template
      TEMPLATES[current_flow]
    end

    def runner__forest_with_flow(node)
      stage = node[:children][0][:children][0]
      block = node[:children][1]
      stages_with_flow(stage, block)
    end

    def stages__forest_with_stages(node)
      stages = evaluate(node[:children][0])
      body = node[:children][1]
      result = nil
      stages.each do |stage|
        result = run_stage(stage.to_sym, body)
      end
      result
    end

    def stages__forest_skip(node)
      evaluate(node)
    end

    def run_stage(stage, node)
      previous_stage = @current_stage
      @current_stage = stage
      result = run_single_stage(@current_stage, node)
      @current_stage = previous_stage
      result
    end

    def run_single_stage(stage, node)
      permissions_options = @global_options[:permissions]
      permissions_per_stage = permissions_options[stage]
      node = clutch(node, permissions_per_stage)
      evaluate(node)
    end


    def clutch(node, permissions)
      if node[:command] == "call"
        if node[:children][0][:command] == "data"
          command_name_node = node[:children][0][:children][0]
          command = command_name_node[:command].strip
          if command == "stages.skip"
            command = command_name_node[:disengaged_command].strip
          end
          if permissions.include?(command)
            command_name_node[:command] = command
          elsif command_name_node[:command] != "stages.skip"
            command_name_node[:disengaged_command] = command
            command_name_node[:command] = "stages.skip"
          end
        end
      end
      node[:children] = node[:children].map do |child|
        clutch(child, permissions)
      end
      node
    end

    def stages_with_flow(stage, block)
      previous_flow = @stages_flow
      @stages_flow = stage
      evaluate(block)
      @stages_flow = previous_flow
    end

    def stages_wrap(tree)
      core_lib_path = @global_options[:core_lib_path]
      @current_flow = @global_options[:flow].to_sym if @global_options[:flow]
      if current_template
        wrapper_path = File.join(core_lib_path, "templates",
          current_template)
        wrapper = parse_file(wrapper_path)
        embed_in_template(wrapper, { yield: tree })
      else
        tree
      end
    end

    def embed_in_template(wrapper, map)
      if (wrapper[:command] == "call")
        called = wrapper[:children][0][:children][0][:command]
        if map.keys.map(&:to_s).include?(called.strip)
          replacement = map[called.to_sym]
          return replacement
        end
      end
      children = wrapper[:children].map do |child|
        new_child = embed_in_template(child, map)
        new_child[:parent] = wrapper
        new_child
      end
      wrapper[:children] = children
      wrapper
    end

    # Notice that we modify stacktrace here,
    # but at the end of the function
    # the stacktrace is back at the initial state
    # Also, have in mind that we check only
    # for stageless permissions until we get to with_stages
    # and after that we check only permissions apart from stageless
    def check_tree(tree, stageless = true)
      with_stacktrace(tree) do
        if tree[:command] == "call"
          check_function_calls(tree, stageless)
          command_name = tree[:children][0][:children][0][:command]
          stageless = false if command_name == "stages.with_stages"
        end
        tree[:children].map do |child|
          check_tree(child, stageless)
        end
      end
    end

    def check_function_calls(tree, stageless)
      command = tree[:children][0][:children][0][:command]
      permissions = @global_options[:permissions]
      return unless permissions

      permissions =
        if stageless
          permissions.select { |k, _v| k == :stageless }
        else
          permissions.select { |k, _v| k != :stageless }
        end

      all_commands = permissions.values.flatten.uniq.map(&:to_s)
      method_name = method_name_of(command)
      if !public_methods.include?(method_name.to_sym)
        raise_forest_code_error(tree, no_method_error_message(command, method_name))
      elsif !all_commands.include?(command)
        raise_forest_code_error(tree, not_permitted_method_error_message(command, stageless))
      end
    end

    def with_stacktrace(node)
      if node[:command] == "call"
        interpreter_add_stack_trace(node)
        result = yield
        remove_stack_trace
        result
      else
        yield
      end
    end
  end
end
