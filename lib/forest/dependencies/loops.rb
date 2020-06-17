class Forest
  module Loops
    # TODO: instead of actually setting 'args' in the context,
    # maybe it would make sense to introduce cgs_context_switch_buffer
    def loops__forest_each_by_name(node)
      args = evaluate(node)
      args['items'].each do |item|
        call_args = { 0 => item }
        call_code_with_context_and_args(args['function'], call_args)
      end
    end

    def loops__forest_each_key_value_by_name(node)
      args = evaluate(node)
      args['items'].each do |key, value|
        call_args = { 'key' => key, 'value' => value }
        call_code_with_context_and_args(args['function'], call_args)
      end
    end

    def call_code_with_context_and_args(code_with_context, args)
      code = code_with_context[:block]
      old_context = cgs_replace_context(code_with_context[:context])
      setup_data # creating a new context
      cgs_internal_set('args', args)
      result = evaluate(code)
      cleanup_data
      cgs_replace_context(old_context)
      result
    end
  end
end
