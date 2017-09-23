class Chef
  class Node
    def recipe?(recipe_name)
      loaded_recipes.include?(with_default(recipe_name))
    end

    private

    #
    # Automatically appends "+::default+" to recipes that need them.
    #
    # @param [String] name
    #
    # @return [String]
    #
    def with_default(name)
      name.include?('::') ? name : "#{name}::default"
    end

    #
    # The list of loaded recipes on the Chef run (normalized)
    #
    # @return [Array<String>]
    #
    def loaded_recipes
      node.run_context.loaded_recipes.map { |name| with_default(name) }
    end
  end
end
