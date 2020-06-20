class Forest
  module CCP # Calculation Context for Permissions
    attr_accessor :ccp_stack

    def ccp_ensure_permissions(action_name, error_node)
      return if !@ccp_stack || @ccp_stack.empty?

      permissions = @ccp_stack && @ccp_stack.last[:permissions]
      action = action_name.strip
      unless permissions.include?(action)
        raise_forest_code_error(error_node, permissions_error_message(action, @ccp_stack, error_node))
      end
    end

    def ccp__forest_with_permissions(node)
      permissions = evaluate(node[:children][0])
      previous_frame = @ccp_stack && !@ccp_stack.empty? && @ccp_stack.last
      previous = previous_frame && previous_frame[:permissions]
      too_broad = previous && permissions.select {|elem| !previous.include? elem }
      if too_broad
        raise_forest_code_error(node, too_broad_permissions_error_message(too_broad, previous_frame))
      end
      if permissions == previous
        evaluate(node[:children][1])
      else
        @ccp_stack ||= []
        @ccp_stack << { node: node[:parent], permissions: permissions }
        result = evaluate(node[:children][1])
        @ccp_stack.pop
        result
      end
    end
  end
end
