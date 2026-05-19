# frozen_string_literal: true

require_relative 'assoc_node'

module LogicalQueryParser
  class AssocResolver
    def initialize(relation, *options)
      @relation = relation
      @options = options.flatten(1)
    end

    def call
      root_node = AssocNode.new(klass: @relation.klass, table_name: @relation.table_name)
      resolve_assocs(@relation.klass, root_node, @options)

      join_relation = @relation.klass.unscoped.joins(root_node.join_structure)
      root_node.descendants.each_with_index do |node, i|
        join_source = join_relation.arel.join_sources[i]
        node.table_name = join_source&.left&.name || node.klass.table_name
      end

      root_node
    end

    private

    def wrap_array(options)
      if options.is_a?(Array)
        options.flatten(1)
      else
        [options]
      end
    end

    def resolve_assocs(current_klass, node, options)
      wrap_array(options).each do |column_or_assoc_hash|
        if column_or_assoc_hash.is_a?(Hash)
          column_or_assoc_hash.each do |assoc_name, nested_column_or_assoc_hash|
            if (reflection = current_klass.reflect_on_association(assoc_name))
              child = AssocNode.new(klass: reflection.klass, assoc_name: assoc_name, parent: node)
              node.children ||= []
              node.children << child
              resolve_assocs(reflection.klass, child, nested_column_or_assoc_hash)
            end
          end
        else
          node.columns ||= []
          node.columns << column_or_assoc_hash
        end
      end
    end
  end
end
