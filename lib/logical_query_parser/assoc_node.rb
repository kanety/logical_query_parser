# frozen_string_literal: true

module LogicalQueryParser
  class AssocNode
    attr_accessor :klass, :assoc_name, :table_name, :columns, :parent, :children

    def initialize(options = {})
      options.each do |key, value|
        send("#{key}=", value)
      end
      @columns ||= []
      @children ||= []
    end

    def model=(model)
      @klass = model
      @table_name = model.table_name
    end

    def descendants
      children.flat_map do |child|
        [child] + child.descendants
      end
    end

    def arel_table
      Arel::Table.new(table_name, as: table_name)
    end

    def join_structure
      if children.empty?
        {}
      else
        children.each_with_object({}) do |child, hash|
          hash[child.assoc_name] = child.join_structure
        end
      end
    end
  end
end
