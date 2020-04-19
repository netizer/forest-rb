class Forest
  module LN
    def ln__forest_later(block)
      block
    end

    def ln__forest_now(block)
      data = evaluate(block)
      code = data[0]
      evaluate(code)
    end
  end
end
