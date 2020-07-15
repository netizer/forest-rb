class Forest
  module Testing
    attr_accessor :testing_logs

    def testing__forest_assert(block)
      data = evaluate(block)
      if data[0] == data[1]
        { result: true }
      else
        raise_forest_code_error(block[:parent], assert_error_message(data[0], data[1]))
      end
    end

    def testing__forest_join(block)
      data = evaluate(block)
      data.join
    end

    def testing__forest_log(block)
      data = evaluate(block)
      @testing_logs ||= []
      @testing_logs << data.first
    end

    def testing__forest_logs(_block)
      testing_logs.join
    end
  end
end
