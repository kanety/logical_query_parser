require 'treetop'
Treetop.load File.expand_path("../logical_query_parser.treetop", __FILE__)

require 'logical_query_parser/version'
require 'logical_query_parser/nodes/base'
require 'logical_query_parser/nodes/active_record' if defined? ActiveRecord::Base

module LogicalQueryParser
  class << self
    def new
      LogicalQueryParserParser.new
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
