# frozen_string_literal: true

require 'treetop'
Treetop.load File.expand_path("../logical_query_parser.treetop", __FILE__)

require 'logical_query_parser/version'
require 'logical_query_parser/assoc_resolver'
require 'logical_query_parser/nodes/base'
require 'logical_query_parser/nodes/active_record' if defined? ::ActiveRecord::Base

module LogicalQueryParser
  class << self
    def new
      LogicalQueryParserParser.new
    end

    def search(query, relations, *options)
      relations = relations.all if relations.respond_to?(:all)
      assoc = resolve_assocs(relations.klass, *options)
      sql = new.parse(query).to_sql(model: relations.klass, columns: assoc.column_mapping)
      relations.joins(assoc.structure).where(sql)
    end

    def resolve_assocs(klass, *options)
      AssocResolver.new(klass).run(*options)
    end

    def walk_tree(node, &block)
      yield node
      unless node.elements.nil?
        node.elements.each do |element|
          walk_tree(element, &block)
        end
      end
    end
  end
end
