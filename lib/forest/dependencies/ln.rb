class Forest
  module LN
    # Uses the following methods from other modules:
    # CGS:
    # - cgs_context_snapshot
    # - cgs_replace_context
    def ln__forest_later(block)
      {
        block: block,
        context: cgs_context_snapshot
      }
    end

    def ln__forest_now(block)
      code_with_context = evaluate(block)
      call_code_with_context(code_with_context)
    end

    def call_code_with_context(code_with_context)
      code = code_with_context[:block]
      old_context = cgs_replace_context(code_with_context[:context])
      result = evaluate(code)
      cgs_replace_context(old_context)
      result
    end

    def ln__forest_now_with_args(block)
      arguments = block[:children][0]
      body = block[:children][1]
      code_with_context = evaluate(body)
      code = code_with_context[:block]
      arguments_result = evaluate(arguments)
      old_context = cgs_replace_context(code_with_context[:context])
      setup_data
      # TODO: assign forest_args and let functions explode them by themselves
      explode(arguments_result)
      result = evaluate(code)
      cleanup_data
      cgs_replace_context(old_context)
      result
    end

    def explode(hash)
      hash.each do |key, value|
        cgs_internal_set(key, value)
      end
    end
  end
end
