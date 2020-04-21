class Forest
  module LN
    def ln__forest_later(block)
      block
    end

    def ln__forest_now(block)
      code = evaluate(block)
      evaluate(code)
    end
  end
end
