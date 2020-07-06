class Forest
  module Cascade
    # TODO: not used
    def find_stages(node)
      if node[:command] == 'data'
        []
      elsif cascade_node?(node)
        [evaluate(node[:children][1][:children][0])]
      else
        node[:children].map do |child|
          find_stages(child)
        end.reduce(:+).uniq
      end
    end

    # TODO: not used
    def runner__forest_cascade(node)
      raise "This method should never be called. It's meant to be found and replaced by runner.load_project_and_run_stages"
    end

    # TODO: not used
    def cascade_node?(node)
      return unless node[:command] == 'call'
      return unless node[:children][0][:command] == 'data'
      return unless node[:children][0][:children][0][:command] == 'cascade'
      true
    end
  end
end
