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
      code = code_with_context[:block]
      old_context = cgs_replace_context(code_with_context[:context])
      result = evaluate(code)
      cgs_replace_context(old_context)
      result
    end
  end
end
